
extends GutTest

# ==============================================================================
# РАЗДЕЛ 1: MOCK-ОБЪЕКТ (СИМУЛЯЦИЯ БИЗНЕС-ЛОГИКИ)
# Описание: Реализация тестируемых алгоритмов в изолированной среде.
# ==============================================================================
class BattleSystemMock:
	extends Node
	
	# Константа точности (Fixed-point precision)
	const FLOAT_ACCURACY = 1000.0
	
	# Сигналы состояния сущности
	signal on_death
	signal on_health_changed(new_value, max_value)
	
	var max_health: float = 100.0
	var current_health: float

	# Инициализация состояния
	func init_health(val: float = 100.0):
		max_health = val
		current_health = val

	# --- ТЕСТИРУЕМАЯ ФУНКЦИЯ №1 ---
	func _int32_to_bytes(value : int) -> PackedByteArray:
		var ret : PackedByteArray
		ret.push_back((value >> 24) & 0xFF)
		ret.push_back((value >> 16) & 0xFF)
		ret.push_back((value >> 8) & 0xFF)
		ret.push_back(value & 0xFF)
		return ret

	# --- ТЕСТИРУЕМАЯ ФУНКЦИЯ №2 ---
	func _get_int32_from_packet(packet : PackedByteArray, from : int, to : int) -> int:
		var ret : int = 0
		# Важно: цикл range(from, to + 1)
		for i : int in range(from, to + 1):
			ret <<= 8
			ret |= packet[i]
		return ret

	# --- ТЕСТИРУЕМАЯ ФУНКЦИЯ №3 ---
	func _vector2_to_bytes(value : Vector2, accuracy : int) -> PackedByteArray:
		var ret : PackedByteArray
		ret.append_array(_int32_to_bytes(int(value.x)))
		ret.append_array(_int32_to_bytes(int(value.x * accuracy ) - int(value.x) * accuracy))
		ret.append_array(_int32_to_bytes(int(value.y)))
		ret.append_array(_int32_to_bytes(int(value.y * accuracy ) - int(value.y) * accuracy))
		return ret

	# --- ТЕСТИРУЕМАЯ ФУНКЦИЯ №4 ---
	func _get_vector2_from_packet(packet : PackedByteArray, from : int) -> Vector2:
		# Проверка минимальной длины (4 int32 * 4 байта = 16 байт)
		if (packet.size()) < (from + 15): # Исправлено на from + 15 (индекс последнего байта)
			print("Error: Packet too small")
			return Vector2.ZERO
			
		var ret : Vector2
		ret.x = _get_int32_from_packet(packet, from, from + 3)
		ret.x += (float(_get_int32_from_packet(packet, from + 4, from + 4 + 3)) / FLOAT_ACCURACY)
		ret.y = _get_int32_from_packet(packet, from + 4 + 4, from + 4 + 4 + 3)
		ret.y += (float(_get_int32_from_packet(packet, from + 4 + 4 + 4, from + 4 + 4 + 4 + 3)) / FLOAT_ACCURACY)
		return ret

	# --- ТЕСТИРУЕМАЯ ФУНКЦИЯ №5 ---
	func take_damage(amount: float):
		if current_health <= 0: return
		current_health -= amount
		if current_health <= 0:
			current_health = 0
			on_death.emit()
		on_health_changed.emit(current_health, max_health)

# ==============================================================================
# РАЗДЕЛ 2: КОНФИГУРАЦИЯ ОКРУЖЕНИЯ
# ==============================================================================
var sys: BattleSystemMock

func before_each():
	sys = BattleSystemMock.new()
	add_child(sys)
	sys.init_health()

func after_each():
	sys.free()

# ==============================================================================
# РАЗДЕЛ 3: ТЕСТОВЫЕ СЦЕНАРИИ
# ==============================================================================

# ------------------------------------------------------------------------------
# ФУНКЦИЯ 1: _int32_to_bytes(value)
# Параметры: value (Int).
# Границы: 0, 1, MaxByte(255), Overflow(256), Negative(-1), MinInt.
# ------------------------------------------------------------------------------

func test_1_01_Boundary_Zero():
	# Сценарий: Входное значение 0 (Нижняя граница беззнакового).
	assert_eq_deep(sys._int32_to_bytes(0), PackedByteArray([0,0,0,0]))

func test_1_02_Boundary_One():
	# Сценарий: Входное значение 1 (Минимальное положительное).
	assert_eq_deep(sys._int32_to_bytes(1), PackedByteArray([0,0,0,1]))

func test_1_03_Boundary_ByteMax():
	# Сценарий: Входное значение 255 (Верхняя граница 1 байта).
	assert_eq_deep(sys._int32_to_bytes(255), PackedByteArray([0,0,0,255]))

func test_1_04_Boundary_ByteOverflow():
	# Сценарий: Входное значение 256 (Переполнение 1 байта, начало 2-го).
	assert_eq_deep(sys._int32_to_bytes(256), PackedByteArray([0,0,1,0]))

func test_1_05_Boundary_TwoBytesMax():
	# Сценарий: Входное значение 65535 (Верхняя граница 2 байт).
	assert_eq_deep(sys._int32_to_bytes(65535), PackedByteArray([0,0,255,255]))

func test_1_06_Boundary_NegativeOne():
	# Сценарий: Входное значение -1 (Все биты установлены в 1, Two's complement).
	assert_eq_deep(sys._int32_to_bytes(-1), PackedByteArray([255,255,255,255]))

func test_1_07_Boundary_NegativeMin():
	# Сценарий: Минимальное знаковое число (старший бит 1, остальные 0).
	assert_eq_deep(sys._int32_to_bytes(-2147483648), PackedByteArray([128,0,0,0]))

func test_1_08_Normal_LargePositive():
	# Сценарий: Произвольное большое положительное число.
	assert_eq_deep(sys._int32_to_bytes(16909060), PackedByteArray([1,2,3,4]))

func test_1_09_Normal_LargeNegative():
	# Сценарий: Произвольное большое отрицательное число.
	assert_eq_deep(sys._int32_to_bytes(-1000), PackedByteArray([255,255,252,24]))

func test_1_10_Structure_Consistency():
	# Сценарий: Проверка структурной целостности (длина массива).
	assert_eq(sys._int32_to_bytes(12345).size(), 4)
#
## ------------------------------------------------------------------------------
## ФУНКЦИЯ 2: _get_int32_from_packet(packet, from, to)
## Параметры: Packet (Array), From (Index), To (Index).
## Комбинаторика: [From:0, To:Normal], [From:Normal, To:End], [From:0, To:End], [SingleByte].
## ------------------------------------------------------------------------------
#
#func test_2_01_Comb_FromBoundZero_ToNorm():
	## Комбинация: From=0 (Граница), To=Середина массива.
	#var p = PackedByteArray([0, 0, 1, 0, 255, 255])
	#assert_eq(sys._get_int32_from_packet(p, 0, 3), 256)
#
#func test_2_02_Comb_FromNorm_ToBoundEnd():
	## Комбинация: From=Середина, To=Последний индекс (Граница).
	#var p = PackedByteArray([255, 255, 0, 0, 0, 10]) # Длина 6, индексы 0..5
	#assert_eq(sys._get_int32_from_packet(p, 2, 5), 10)
#
#func test_2_03_Comb_BothBound_FullBuffer():
	## Комбинация: From=0 (Граница), To=Конец (Граница).
	#var p = PackedByteArray([0, 0, 0, 5])
	#assert_eq(sys._get_int32_from_packet(p, 0, 3), 5)
#
#func test_2_04_Comb_SameIndex_SingleByte():
	## Комбинация: From == To (Минимальный диапазон).
	#var p = PackedByteArray([0, 10, 20, 30])
	#assert_eq(sys._get_int32_from_packet(p, 1, 1), 10)
#
#func test_2_05_Val_ZeroDecode():
	## Значение: Десериализация нулевых байтов.
	#assert_eq(sys._get_int32_from_packet(PackedByteArray([0,0,0,0]), 0, 3), 0)
#
#func test_2_06_Val_MaxDecode():
	## Значение: Десериализация максимальных байтов (0xFF).
	## Ожидается Unsigned Int32 Max (4294967295) из-за особенностей int64 в Godot.
	#assert_eq(sys._get_int32_from_packet(PackedByteArray([255,255,255,255]), 0, 3), 4294967295)
#
#func test_2_07_Structure_EmptyRange():
	## Негативный сценарий: From > To (Пустой диапазон).
	## Ожидается возврат 0 (инициализированное значение).
	#assert_eq(sys._get_int32_from_packet(PackedByteArray([1,2,3]), 2, 1), 0)
#
#func test_2_08_Structure_OffsetShift():
	## Норма: Проверка корректности смещения в большом массиве.
	#var p = PackedByteArray([1, 2, 3, 4, 5, 6, 7, 8])
	## Читаем индексы 4..7 (5,6,7,8) -> 0x05060708 = 84281096
	#assert_eq(sys._get_int32_from_packet(p, 4, 7), 84281096)
#
#func test_2_09_Val_NegativePattern():
	## Значение: Паттерн, соответствующий -1 в 32-бит.
	#var p = PackedByteArray([255, 255, 255, 255])
	#var res = sys._get_int32_from_packet(p, 0, 3)
	## Проверка битовой маски
	#assert_eq(res & 0xFFFFFFFF, 0xFFFFFFFF)
#
#func test_2_10_Comb_NegativeIndices():
	## Негативный сценарий: Отрицательные индексы (Недопустимо).
	## В Godot доступ по индексу -1 берет элемент с конца, проверим поведение алгоритма.
	#var p = PackedByteArray([0,0,0,5])
	## range(0, 0) -> пустой цикл -> return 0. Ошибки нет, но логика сломана.
	## Тест фиксирует безопасное поведение (не краш).
	#sys._get_int32_from_packet(p, 0, -1) 
	#pass_test("Вызов с отрицательным индексом не вызвал критический сбой")
#
## ------------------------------------------------------------------------------
## ФУНКЦИЯ 3: _vector2_to_bytes(value, accuracy)
## Параметры: Value (Vector2), Accuracy (Int).
## Матрица: [Vec:Bound, Acc:Norm], [Vec:Norm, Acc:Bound], [Vec:Neg, Acc:Norm], [Vec:Norm, Acc:Neg].
## ------------------------------------------------------------------------------
#
#func test_3_01_Comb_VecZero_AccNorm():
	## Комбинация: Вектор Zero (Граница), Точность 1000 (Норма).
	#var res = sys._vector2_to_bytes(Vector2.ZERO, 1000)
	#assert_eq_deep(res, PackedByteArray([0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]))
#
#func test_3_02_Comb_VecNorm_AccOne():
	## Комбинация: Вектор Норма, Точность 1 (Минимальная граница).
	## Дробная часть должна обнулиться. 1.5 * 1 = 1.
	#var res = sys._vector2_to_bytes(Vector2(1.5, 1.5), 1)
	#assert_eq(sys._get_int32_from_packet(res, 4, 7), 0) # Дробная часть X
#
#func test_3_03_Comb_VecNeg_AccNorm():
	## Комбинация: Вектор Отрицательный (Граница знака), Точность Норма.
	#var res = sys._vector2_to_bytes(Vector2(-1, -1), 1000)
	#assert_eq(res[0], 255) # Проверка старшего байта (знак)
#
#func test_3_04_Comb_VecNorm_AccLarge():
	## Комбинация: Вектор Норма, Точность Максимальная (Граница).
	#var res = sys._vector2_to_bytes(Vector2(1.12345, 0), 100000)
	## Проверка сохранения 5 знаков.
	#assert_eq(sys._get_int32_from_packet(res, 4, 7), 12345)
#
#func test_3_05_Comb_BothBound_VecMax_AccMin():
	## Комбинация: Вектор MaxInt, Точность 1.
	#var large = 2147483.0 # Примерное большое число
	#var res = sys._vector2_to_bytes(Vector2(large, large), 1)
	#assert_eq(res.size(), 16)
#
#func test_3_06_Val_FractionTruncation():
	## Значение: Проверка потери точности (значение < 1/Accuracy).
	#var res = sys._vector2_to_bytes(Vector2(0.0001, 0), 1000)
	#assert_eq(sys._get_int32_from_packet(res, 4, 7), 0)
#
#func test_3_07_Val_MixedSigns():
	## Значение: X положительный, Y отрицательный.
	#var res = sys._vector2_to_bytes(Vector2(10, -10), 1000)
	#assert_eq(sys._get_int32_from_packet(res, 0, 3), 10) # X int
	#assert_eq(sys._get_int32_from_packet(res, 8, 11) & 0xFFFFFFFF, 4294967286) # Y int (-10)
#
#func test_3_08_Val_OnlyFraction():
	## Значение: Только дробная часть (0.123).
	#var res = sys._vector2_to_bytes(Vector2(0.123, 0), 1000)
	#assert_eq(sys._get_int32_from_packet(res, 0, 3), 0) # Целая часть 0
	#assert_eq(sys._get_int32_from_packet(res, 4, 7), 123) # Дробная 123
#
#func test_3_09_Acc_Negative():
	## Негативный сценарий: Отрицательная точность.
	## Алгоритм: int(x * -1000) - ...
	#var res = sys._vector2_to_bytes(Vector2(1.5, 0), -1000)
	## Проверяем, что не крашится, результат будет математически странным, но валидным байт-массивом.
	#assert_eq(res.size(), 16)
#
#func test_3_10_Acc_Zero():
	## Негативный сценарий: Точность 0.
	## value * 0 = 0.
	#var res = sys._vector2_to_bytes(Vector2(1.5, 1.5), 0)
	#assert_eq(sys._get_int32_from_packet(res, 4, 7), 0)
#
#func test_3_11_Boundary_X_Zero_Y_Max():
	## Комбинация: X на границе 0, Y на границе Max.
	#var res = sys._vector2_to_bytes(Vector2(0, 99999), 1000)
	#assert_eq(sys._get_int32_from_packet(res, 0, 3), 0)
	#assert_eq(sys._get_int32_from_packet(res, 8, 11), 99999)
#
#func test_3_12_Boundary_X_Min_Y_Zero():
	## Комбинация: X на границе Min (-99999), Y на границе 0.
	#var res = sys._vector2_to_bytes(Vector2(-99999, 0), 1000)
	#assert_eq(res[0], 255) # Знак минус
	#assert_eq(sys._get_int32_from_packet(res, 8, 11), 0)
#
## ------------------------------------------------------------------------------
## ФУНКЦИЯ 4: _get_vector2_from_packet(packet, from)
## Параметры: Packet (Array), From (Index).
## Матрица: [Size:Min, From:0], [Size:Max, From:Offset], [Size:Inv, From:0].
## ------------------------------------------------------------------------------
#
#func test_4_01_Comb_SizeExact_FromZero():
	## Комбинация: Размер пакета ровно 16 байт (Граница), From=0.
	#var p = PackedByteArray(); p.resize(16); p.fill(0)
	#var v = sys._get_vector2_from_packet(p, 0)
	#assert_eq(v, Vector2.ZERO)
#
#func test_4_02_Comb_SizeLarge_FromOffset():
	## Комбинация: Размер большой (Норма), From=Смещение (Норма).
	#var padding = PackedByteArray([0,0,0,0])
	#var data = sys._vector2_to_bytes(Vector2(1,1), 1000)
	#padding.append_array(data)
	#var v = sys._get_vector2_from_packet(padding, 4)
	#assert_eq(v.x, 1.0)
#
#func test_4_03_Comb_SizeSmall_FromZero():
	## Негативный сценарий: Пакет меньше необходимого (15 байт).
	#var p = PackedByteArray(); p.resize(15); p.fill(0)
	#var v = sys._get_vector2_from_packet(p, 0)
	#assert_eq(v, Vector2.ZERO) # Ожидается возврат ошибки (ZERO)
#
#func test_4_04_Comb_SizeExact_FromInvalid():
	## Негативный сценарий: Пакет валидный (16), но From указывает за границы.
	#var p = PackedByteArray(); p.resize(16)
	#var v = sys._get_vector2_from_packet(p, 16)
	#assert_eq(v, Vector2.ZERO)
#
#func test_4_05_Val_RoundTrip_Positive():
	## Значение: Восстановление положительного дробного вектора.
	#var orig = Vector2(10.5, 20.123)
	#var p = sys._vector2_to_bytes(orig, 1000)
	#var res = sys._get_vector2_from_packet(p, 0)
	#assert_almost_eq(res.x, orig.x, 0.001)
#
#func test_4_06_Val_RoundTrip_Negative():
	## Значение: Восстановление отрицательного дробного вектора.
	#var orig = Vector2(-5.5, -0.999)
	#var p = sys._vector2_to_bytes(orig, 1000)
	#var res = sys._get_vector2_from_packet(p, 0)
	#assert_almost_eq(res.y, orig.y, 0.001)
#
#func test_4_07_Val_RoundTrip_Mixed():
	## Значение: Смешанные знаки (+, -).
	#var orig = Vector2(50.0, -50.0)
	#var p = sys._vector2_to_bytes(orig, 1000)
	#var res = sys._get_vector2_from_packet(p, 0)
	#assert_almost_eq(res.x, 50.0, 0.001)
	#assert_almost_eq(res.y, -50.0, 0.001)
#
#func test_4_08_Val_PrecisionLimit():
	## Значение: Проверка предела точности (восстановление 0.001).
	#var orig = Vector2(0.001, 0.001)
	#var p = sys._vector2_to_bytes(orig, 1000)
	#var res = sys._get_vector2_from_packet(p, 0)
	#assert_almost_eq(res.x, 0.001, 0.0001)
#
#func test_4_09_Stability_Noise():
	## Устойчивость: Обработка массива со случайными значениями.
	#var p = PackedByteArray([255,12,33,44, 55,66,77,88, 0,1,2,3, 4,5,6,7])
	#var v = sys._get_vector2_from_packet(p, 0)
	#assert_ne(v, null)
#
#func test_4_10_Comb_SizeLarge_FromEndBoundary():
	## Комбинация: Большой пакет, но From указывает слишком близко к концу.
	## Length 20, From 10. Available = 10. Need 16. -> Fail.
	#var p = PackedByteArray(); p.resize(20)
	#var v = sys._get_vector2_from_packet(p, 10)
	#assert_eq(v, Vector2.ZERO)
#
#func test_4_11_Boundary_PacketMaxValues():
	## Граница: Пакет заполнен 0xFF.
	#var p = PackedByteArray(); p.resize(16); p.fill(255)
	## Это приведет к декодированию очень маленьких отрицательных чисел (из-за переполнения).
	## Главное - отсутствие сбоя.
	#var v = sys._get_vector2_from_packet(p, 0)
	#assert_ne(v, Vector2.ZERO)
#
#func test_4_12_Boundary_From_Negative():
	## Негативный сценарий: From отрицательный.
	#var p = PackedByteArray(); p.resize(16)
	#var v = sys._get_vector2_from_packet(p, -1)
	## Ожидается срабатывание защиты по размеру (size < from + 15).
	#assert_eq(v, Vector2.ZERO)
#
## ------------------------------------------------------------------------------
## ФУНКЦИЯ 5: take_damage(amount)
## Параметры: Amount (Float).
## Состояние: CurrentHealth.
## Матрица: [HP:Full, Dmg:Bound], [HP:Full, Dmg:Norm], [HP:Low, Dmg:Overkill], [HP:Zero, Dmg:Any].
## ------------------------------------------------------------------------------
#
#func test_5_01_Comb_HpMax_DmgZero():
	## Комбинация: Здоровье Макс (Граница), Урон 0 (Граница).
	#sys.init_health(100)
	#sys.take_damage(0)
	#assert_eq(sys.current_health, 100.0)
#
#func test_5_02_Comb_HpMax_DmgNormal():
	## Комбинация: Здоровье Макс (Граница), Урон Норма (50).
	#sys.init_health(100)
	#sys.take_damage(50)
	#assert_eq(sys.current_health, 50.0)
#
#func test_5_03_Comb_HpMax_DmgLethal():
	## Комбинация: Здоровье Макс, Урон Летальный (равен HP).
	#sys.init_health(100)
	#sys.take_damage(100)
	#assert_eq(sys.current_health, 0.0)
	#assert_signal_emitted(sys, "on_death")
#
#func test_5_04_Comb_HpMax_DmgOverkill():
	## Комбинация: Здоровье Макс, Урон Избыточный (Больше HP).
	#sys.init_health(100)
	#sys.take_damage(999.0)
	#assert_eq(sys.current_health, 0.0)
	#assert_signal_emitted(sys, "on_death")
#
#func test_5_05_Comb_HpLow_DmgLethal():
	## Комбинация: Здоровье Низкое (Норма), Урон Летальный.
	#sys.init_health(10.0)
	#sys.take_damage(10.0)
	#assert_eq(sys.current_health, 0.0)
#
#func test_5_06_Comb_HpZero_DmgNormal():
	## Комбинация: Здоровье 0 (Граница), Урон Норма.
	#sys.init_health(0.0)
	#watch_signals(sys)
	#sys.take_damage(10)
	#assert_eq(sys.current_health, 0.0)
	#assert_signal_not_emitted(sys, "on_death") # Не умирать дважды
#
#func test_5_07_Val_NegativeDamage():
	## Значение: Отрицательный урон (Лечение).
	#sys.init_health(50)
	#sys.take_damage(-20)
	#assert_eq(sys.current_health, 70.0)
#
#func test_5_08_Val_FractionalDamage():
	## Значение: Дробный урон.
	#sys.init_health(10)
	#sys.take_damage(0.5)
	#assert_eq(sys.current_health, 9.5)
#
#func test_5_09_Val_SmallestDamage():
	## Значение: Минимальный значимый урон.
	#sys.init_health(10)
	#sys.take_damage(0.0001)
	#assert_lt(sys.current_health, 10.0)
#
#func test_5_10_State_MaxHealthChange():
	## Состояние: Изменение MaxHealth перед уроном.
	#sys.init_health(200) # Граница MaxHealth изменена
	#sys.take_damage(50)
	#assert_eq(sys.current_health, 150.0)
#
#func test_5_11_Signal_ParamsCheck():
	## Логика: Валидация параметров сигнала.
	#sys.init_health(100)
	#watch_signals(sys)
	#sys.take_damage(10)
	## Проверка: (90, 100)
	#assert_signal_emitted_with_parameters(sys, "on_health_changed", [90.0, 100.0])
#
#func test_5_12_Comb_HpNearZero_DmgNonLethal():
	## Комбинация: HP близко к 0, Урон не летальный.
	#sys.init_health(1.0)
	#sys.take_damage(0.9)
	#assert_almost_eq(sys.current_health, 0.1, 0.01)
	#assert_signal_not_emitted(sys, "on_death")
#
#func test_5_13_Comb_HpNearZero_DmgExact():
	## Комбинация: HP близко к 0, Урон точный.
	#sys.init_health(0.1)
	#sys.take_damage(0.1)
	#assert_eq(sys.current_health, 0.0)
	#assert_signal_emitted(sys, "on_death")
#
#func test_5_14_Logic_RepeatedDamage():
	## Логика: Последовательный урон.
	#sys.init_health(100)
	#sys.take_damage(50)
	#sys.take_damage(20)
	#assert_eq(sys.current_health, 30.0)
