Функция ЗагрузитьШаблоны(ПутьКШаблонам, ШаблоныПоУмолчанию) Экспорт

	Если НЕ ЗначениеЗаполнено(ПутьКШаблонам) Тогда
		
		ПутьКШаблонам = ОбъединитьПути(СтартовыйСценарий().Каталог, "additional", ШаблоныПоУмолчанию);
		
	КонецЕсли;
	
	Текст = Новый ТекстовыйДокумент;
	Текст.Прочитать(ПутьКШаблонам, "UTF-8");
	СодержимоеШаблона = Текст.ПолучитьТекст();
	ПарсерJSON = Новый ПарсерJSON;
	ПредШаблоны = ПарсерJSON.ПрочитатьJSON(СодержимоеШаблона);
	Шаблоны = Новый Структура;
	Для Каждого Элемент Из ПредШаблоны Цикл
		
		Шаблоны.Вставить(Элемент.Ключ, СтрЗаменить(Элемент.Значение, """", "\"""));
		
	КонецЦикла;
	
	Возврат Шаблоны;
	
КонецФункции

Функция ПолучитьМассивПодсистемИзОписания(МассивОписанийКонстант, МассивРодительскихПодсистем) Экспорт
	
	МассивПодсистем = Новый Массив;
	
	Для Каждого ОписаниеКонстанты Из МассивОписанийКонстант Цикл
		
		РазборПодсистемы = СтрРазделить(ОписаниеКонстанты.Подсистема, ".");
		Если РазборПодсистемы.Количество() < 2 Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		МассивПодсистем.Добавить(ОписаниеКонстанты.Подсистема);
		
		Если МассивРодительскихПодсистем.Найти(РазборПодсистемы[1]) = Неопределено Тогда
			
			МассивРодительскихПодсистем.Добавить(РазборПодсистемы[1]);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат МассивПодсистем;
	
КонецФункции

Функция ПолучитьПотомков(МассивОписанийПодсистем, Родитель) Экспорт
	
	МассивИменПодсистем = Новый Массив;
	
	Для Каждого ОписаниеПодсистема Из МассивОписанийПодсистем Цикл
		
		Если СтрНайти(ОписаниеПодсистема, Родитель) Тогда
			
			РазборПодсистемы = СтрРазделить(ОписаниеПодсистема, ".");
			
			Если РазборПодсистемы.Количество() = 3 Тогда
				
				Если МассивИменПодсистем.Найти(РазборПодсистемы[2]) = Неопределено Тогда
					
					МассивИменПодсистем.Добавить(РазборПодсистемы[2]);
					
				КонецЕсли;
				
			ИначеЕсли РазборПодсистемы.Количество() = 2 Тогда
				
				Если МассивИменПодсистем.Найти(РазборПодсистемы[1]) = Неопределено Тогда
					
					МассивИменПодсистем.Добавить(РазборПодсистемы[1]);
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат МассивИменПодсистем;
	
КонецФункции
