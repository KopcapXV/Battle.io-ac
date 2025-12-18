extends GutTest

# ==============================================================================
# РАЗДЕЛ 1: MOCK-ОБЪЕКТ (СИМУЛЯЦИЯ БИЗНЕС-ЛОГИКИ)
# ==============================================================================
class BattleSystemMock:
	extends Node
	
	const FLOAT_ACCURACY = 1000.0
	
	signal on_death
	signal on_health_changed(new_value, max_value)
	
	var max_health: float = 100.0
	var current_health: float

	func init_health(val: float = 100.0):
		max_health = val
		current_health = val

	# --- ФУНКЦИЯ 1 ---
	func _int32_to_bytes(value : int) -> PackedByteArray:
		var ret : PackedByteArray
		ret.push_back((value >> 24) & 0xFF)
		ret.push_back((value >> 16) & 0xFF)
		ret.push_back((value >> 8) & 0xFF)
		ret.push_back(value & 0xFF)
		return ret

	# --- ФУНКЦИЯ 2 ---
	func _get_int32_from_packet(packet : PackedByteArray, from : int, to : int) -> int:
		var ret : int = 0
		for i : int in range(from, to + 1):
			ret <<= 8
			ret |= packet[i]
		
		if ret > 2147483647:
			ret -= 4294967296
			
		return ret

	# --- ФУНКЦИЯ 3 ---
	func _vector2_to_bytes(value : Vector2, accuracy : int) -> PackedByteArray:
		var ret : PackedByteArray
		ret.append_array(_int32_to_bytes(int(value.x)))
		ret.append_array(_int32_to_bytes(int(value.x * accuracy ) - int(value.x) * accuracy))
		ret.append_array(_int32_to_bytes(int(value.y)))
		ret.append_array(_int32_to_bytes(int(value.y * accuracy ) - int(value.y) * accuracy))
		return ret

	# --- ФУНКЦИЯ 4 ---
	func _get_vector2_from_packet(packet : PackedByteArray, from : int) -> Vector2:
		if (packet.size()) < (from + 16): 
			return Vector2.ZERO
			
		var ret : Vector2
		ret.x = _get_int32_from_packet(packet, from, from + 3)
		ret.x += (float(_get_int32_from_packet(packet, from + 4, from + 4 + 3)) / FLOAT_ACCURACY)
		ret.y = _get_int32_from_packet(packet, from + 4 + 4, from + 4 + 4 + 3)
		ret.y += (float(_get_int32_from_packet(packet, from + 4 + 4 + 4, from + 4 + 4 + 4 + 3)) / FLOAT_ACCURACY)
		return ret

	# --- ФУНКЦИЯ 5 ---
	func take_damage(amount: float):
		if current_health <= 0: return
		current_health -= amount
		if current_health <= 0:
			current_health = 0
			on_death.emit()
		on_health_changed.emit(current_health, max_health)

# ==============================================================================
# РАЗДЕЛ 2: КОНФИГУРАЦИЯ
# ==============================================================================
var sys: BattleSystemMock

func before_each():
	sys = BattleSystemMock.new()
	add_child(sys)
	sys.init_health()

func after_each():
	sys.free()

 #==============================================================================
 # РАЗДЕЛ 3: ТЕСТЫ (58 СЦЕНАРИЕВ)
 #==============================================================================

# --- ГРУППА 1: _int32_to_bytes ---

func test_1_01_Boundary_Zero():
	assert_eq_deep(sys._int32_to_bytes(0), PackedByteArray([0,0,0,0]))

func test_1_02_Boundary_One():
	assert_eq_deep(sys._int32_to_bytes(1), PackedByteArray([0,0,0,1]))

func test_1_03_Boundary_ByteMax():
	assert_eq_deep(sys._int32_to_bytes(255), PackedByteArray([0,0,0,255]))

func test_1_04_Boundary_ByteOverflow():
	assert_eq_deep(sys._int32_to_bytes(256), PackedByteArray([0,0,1,0]))

func test_1_05_Boundary_TwoBytesMax():
	assert_eq_deep(sys._int32_to_bytes(65535), PackedByteArray([0,0,255,255]))

func test_1_06_Boundary_NegativeOne():
	assert_eq_deep(sys._int32_to_bytes(-1), PackedByteArray([255,255,255,255]))

func test_1_07_Boundary_NegativeMin():
	assert_eq_deep(sys._int32_to_bytes(-2147483648), PackedByteArray([128,0,0,0]))

func test_1_08_Normal_LargePositive():
	assert_eq_deep(sys._int32_to_bytes(16909060), PackedByteArray([1,2,3,4]))

func test_1_09_Normal_LargeNegative():
	assert_eq_deep(sys._int32_to_bytes(-1000), PackedByteArray([255,255,252,24]))

func test_1_10_Structure_Consistency():
	assert_eq(sys._int32_to_bytes(12345).size(), 4)


# --- ГРУППА 2: _get_int32_from_packet ---

func test_2_01_Comb_FromBoundZero_ToNorm():
	var p = PackedByteArray([0, 0, 1, 0, 255, 255])
	assert_eq(sys._get_int32_from_packet(p, 0, 3), 256)

func test_2_02_Comb_FromNorm_ToBoundEnd():
	var p = PackedByteArray([255, 255, 0, 0, 0, 10]) 
	assert_eq(sys._get_int32_from_packet(p, 2, 5), 10)

func test_2_03_Comb_BothBound_FullBuffer():
	var p = PackedByteArray([0, 0, 0, 5])
	assert_eq(sys._get_int32_from_packet(p, 0, 3), 5)

func test_2_04_Comb_SameIndex_SingleByte():
	var p = PackedByteArray([0, 10, 20, 30])
	assert_eq(sys._get_int32_from_packet(p, 1, 1), 10)

func test_2_05_Val_ZeroDecode():
	assert_eq(sys._get_int32_from_packet(PackedByteArray([0,0,0,0]), 0, 3), 0)

func test_2_06_Val_MaxDecode():
	assert_eq(sys._get_int32_from_packet(PackedByteArray([255,255,255,255]), 0, 3), -1)

func test_2_07_Structure_EmptyRange():
	assert_eq(sys._get_int32_from_packet(PackedByteArray([1,2,3]), 2, 1), 0)

func test_2_08_Structure_OffsetShift():
	var p = PackedByteArray([1, 2, 3, 4, 5, 6, 7, 8])
	assert_eq(sys._get_int32_from_packet(p, 4, 7), 84281096)

func test_2_09_Val_NegativePattern():
	var p = PackedByteArray([255, 255, 255, 255])
	assert_eq(sys._get_int32_from_packet(p, 0, 3), -1)

func test_2_10_Comb_NegativeIndices():
	var p = PackedByteArray([0,0,0,5])
	sys._get_int32_from_packet(p, 0, -1) 
	pass_test("Безопасное выполнение с неверными индексами")


# --- ГРУППА 3: _vector2_to_bytes ---

func test_3_01_Comb_VecZero_AccNorm():
	var res = sys._vector2_to_bytes(Vector2.ZERO, 1000)
	assert_eq_deep(res, PackedByteArray([0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]))

func test_3_02_Comb_VecNorm_AccOne():
	var res = sys._vector2_to_bytes(Vector2(1.5, 1.5), 1)
	assert_eq(sys._get_int32_from_packet(res, 4, 7), 0) 

func test_3_03_Comb_VecNeg_AccNorm():
	var res = sys._vector2_to_bytes(Vector2(-1, -1), 1000)
	assert_eq(res[0], 255) 

func test_3_04_Comb_VecNorm_AccLarge():
	var res = sys._vector2_to_bytes(Vector2(1.12345, 0), 100000)
	assert_eq(sys._get_int32_from_packet(res, 4, 7), 12345)

func test_3_05_Comb_BothBound_VecMax_AccMin():
	var large = 2147483.0
	var res = sys._vector2_to_bytes(Vector2(large, large), 1)
	assert_eq(res.size(), 16)

func test_3_06_Val_FractionTruncation():
	var res = sys._vector2_to_bytes(Vector2(0.0001, 0), 1000)
	assert_eq(sys._get_int32_from_packet(res, 4, 7), 0)

func test_3_07_Val_MixedSigns():
	var res = sys._vector2_to_bytes(Vector2(10, -10), 1000)
	assert_eq(sys._get_int32_from_packet(res, 0, 3), 10) 
	assert_eq(sys._get_int32_from_packet(res, 8, 11), -10) 

func test_3_08_Val_OnlyFraction():
	var res = sys._vector2_to_bytes(Vector2(0.123, 0), 1000)
	assert_eq(sys._get_int32_from_packet(res, 0, 3), 0)
	assert_eq(sys._get_int32_from_packet(res, 4, 7), 123)

func test_3_09_Acc_Negative():
	var res = sys._vector2_to_bytes(Vector2(1.5, 0), -1000)
	assert_eq(res.size(), 16)

func test_3_10_Acc_Zero():
	var res = sys._vector2_to_bytes(Vector2(1.5, 1.5), 0)
	assert_eq(sys._get_int32_from_packet(res, 4, 7), 0)

func test_3_11_Boundary_X_Zero_Y_Max():
	var res = sys._vector2_to_bytes(Vector2(0, 99999), 1000)
	assert_eq(sys._get_int32_from_packet(res, 0, 3), 0)
	assert_eq(sys._get_int32_from_packet(res, 8, 11), 99999)

func test_3_12_Boundary_X_Min_Y_Zero():
	var res = sys._vector2_to_bytes(Vector2(-99999, 0), 1000)
	assert_eq(res[0], 255) 
	assert_eq(sys._get_int32_from_packet(res, 8, 11), 0)


# --- ГРУППА 4: _get_vector2_from_packet ---

func test_4_01_Comb_SizeExact_FromZero():
	var p = PackedByteArray(); p.resize(16); p.fill(0)
	var v = sys._get_vector2_from_packet(p, 0)
	assert_eq(v, Vector2.ZERO)

func test_4_02_Comb_SizeLarge_FromOffset():
	var padding = PackedByteArray([0,0,0,0])
	var data = sys._vector2_to_bytes(Vector2(1,1), 1000)
	padding.append_array(data)
	var v = sys._get_vector2_from_packet(padding, 4)
	assert_eq(v.x, 1.0)

func test_4_03_Comb_SizeSmall_FromZero():
	var p = PackedByteArray(); p.resize(15); p.fill(0)
	var v = sys._get_vector2_from_packet(p, 0)
	assert_eq(v, Vector2.ZERO)

func test_4_04_Comb_SizeExact_FromInvalid():
	var p = PackedByteArray(); p.resize(16)
	var v = sys._get_vector2_from_packet(p, 16)
	assert_eq(v, Vector2.ZERO)

func test_4_05_Val_RoundTrip_Positive():
	var orig = Vector2(10.5, 20.123)
	var p = sys._vector2_to_bytes(orig, 1000)
	var res = sys._get_vector2_from_packet(p, 0)
	assert_almost_eq(res.x, orig.x, 0.001)

func test_4_06_Val_RoundTrip_Negative():
	var orig = Vector2(-5.5, -0.999)
	var p = sys._vector2_to_bytes(orig, 1000)
	var res = sys._get_vector2_from_packet(p, 0)
	assert_almost_eq(res.y, orig.y, 0.001)

func test_4_07_Val_RoundTrip_Mixed():
	var orig = Vector2(50.0, -50.0)
	var p = sys._vector2_to_bytes(orig, 1000)
	var res = sys._get_vector2_from_packet(p, 0)
	assert_almost_eq(res.x, 50.0, 0.001)
	assert_almost_eq(res.y, -50.0, 0.001)

func test_4_08_Val_PrecisionLimit():
	var orig = Vector2(0.001, 0.001)
	var p = sys._vector2_to_bytes(orig, 1000)
	var res = sys._get_vector2_from_packet(p, 0)
	assert_almost_eq(res.x, 0.001, 0.0001)

func test_4_09_Stability_Noise():
	var p = PackedByteArray([255,12,33,44, 55,66,77,88, 0,1,2,3, 4,5,6,7])
	var v = sys._get_vector2_from_packet(p, 0)
	assert_ne(v, null)

func test_4_10_Comb_SizeLarge_FromEndBoundary():
	var p = PackedByteArray(); p.resize(20)
	var v = sys._get_vector2_from_packet(p, 10)
	assert_eq(v, Vector2.ZERO)

func test_4_11_Boundary_PacketMaxValues():
	var p = PackedByteArray(); p.resize(16); p.fill(255)
	var v = sys._get_vector2_from_packet(p, 0)
	assert_ne(v, Vector2.ZERO)

func test_4_12_Boundary_From_Negative():
	var p = PackedByteArray(); p.resize(16)
	var v = sys._get_vector2_from_packet(p, -1)
	assert_eq(v, Vector2.ZERO)


# --- ГРУППА 5: take_damage ---

func test_5_01_Comb_HpMax_DmgZero():
	sys.init_health(100)
	sys.take_damage(0)
	assert_eq(sys.current_health, 100.0)

func test_5_02_Comb_HpMax_DmgNormal():
	sys.init_health(100)
	watch_signals(sys)
	sys.take_damage(50)
	assert_eq(sys.current_health, 50.0)
	assert_signal_emitted(sys, "on_health_changed")

func test_5_03_Comb_HpMax_DmgLethal():
	sys.init_health(100)
	watch_signals(sys) 
	sys.take_damage(100)
	assert_eq(sys.current_health, 0.0)
	assert_signal_emitted(sys, "on_death")

func test_5_04_Comb_HpMax_DmgOverkill():
	sys.init_health(100)
	watch_signals(sys)
	sys.take_damage(999.0)
	assert_eq(sys.current_health, 0.0)
	assert_signal_emitted(sys, "on_death")

func test_5_05_Comb_HpLow_DmgLethal():
	sys.init_health(10.0)
	watch_signals(sys)
	sys.take_damage(10.0)
	assert_eq(sys.current_health, 0.0)
	assert_signal_emitted(sys, "on_death")

func test_5_06_Comb_HpZero_DmgNormal():
	sys.init_health(0.0)
	watch_signals(sys)
	sys.take_damage(10)
	assert_eq(sys.current_health, 0.0)
	assert_signal_not_emitted(sys, "on_death")

func test_5_07_Val_NegativeDamage():
	sys.init_health(50)
	sys.take_damage(-20)
	assert_eq(sys.current_health, 70.0)

func test_5_08_Val_FractionalDamage():
	sys.init_health(10)
	sys.take_damage(0.5)
	assert_eq(sys.current_health, 9.5)

func test_5_09_Val_SmallestDamage():
	sys.init_health(10)
	sys.take_damage(0.0001)
	assert_lt(sys.current_health, 10.0)

func test_5_10_State_MaxHealthChange():
	sys.init_health(200)
	sys.take_damage(50)
	assert_eq(sys.current_health, 150.0)

func test_5_11_Signal_ParamsCheck():
	sys.init_health(100)
	watch_signals(sys)
	sys.take_damage(10)
	assert_signal_emitted_with_parameters(sys, "on_health_changed", [90.0, 100.0])

func test_5_12_Comb_HpNearZero_DmgNonLethal():
	sys.init_health(1.0)
	watch_signals(sys)
	sys.take_damage(0.9)
	assert_almost_eq(sys.current_health, 0.1, 0.01)
	assert_signal_not_emitted(sys, "on_death")

func test_5_13_Comb_HpNearZero_DmgExact():
	sys.init_health(0.1)
	watch_signals(sys)
	sys.take_damage(0.1)
	assert_eq(sys.current_health, 0.0)
	assert_signal_emitted(sys, "on_death")

func test_5_14_Logic_RepeatedDamage():
	sys.init_health(100)
	sys.take_damage(50)
	sys.take_damage(20)
	assert_eq(sys.current_health, 30.0)
