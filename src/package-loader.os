﻿Процедура ПриЗагрузкеБиблиотеки(Путь, СтандартнаяОбработка, Отказ)
	
	СтандартнаяОбработка = ЛОЖЬ;	
	ОбработатьСтруктуруКаталоговПоСоглашению(Путь, СтандартнаяОбработка, Отказ);
	
КонецПроцедуры

Процедура ОбработатьСтруктуруКаталоговПоСоглашению(Путь, СтандартнаяОбработка, Отказ)
	
	КаталогиКлассов = Новый Массив;
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "Классы"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "Classes"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "Команды"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "src", "Классы"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "src", "Classes"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "src", "Команды"));
	
	КаталогиМодулей = Новый Массив;
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "Модули"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "Modules"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "Перечисления"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "src", "Модули"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "src", "Modules"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "src", "Перечисления"));
	
	
	Для Каждого мКаталог Из КаталогиКлассов Цикл
		
		ОбработатьКаталогКлассов(мКаталог, СтандартнаяОбработка, Отказ);
		
	КонецЦикла;
	
	Для Каждого мКаталог Из КаталогиМодулей Цикл
		
		ОбработатьКаталогМодулей(мКаталог, СтандартнаяОбработка, Отказ);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработатьКаталогКлассов(Знач Путь, СтандартнаяОбработка, Отказ)
	
	КаталогКлассов = Новый Файл(Путь);
	
	Если КаталогКлассов.Существует() Тогда
		Файлы = НайтиФайлы(КаталогКлассов.ПолноеИмя, "*.os");
		Для Каждого Файл Из Файлы Цикл
			СтандартнаяОбработка = Ложь;
			ДобавитьКлассЕслиРанееНеДобавляли(Файл.ПолноеИмя, Файл.ИмяБезРасширения);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьКаталогМодулей(Знач Путь, СтандартнаяОбработка, Отказ)
	
	КаталогМодулей = Новый Файл(Путь);
	
	Если КаталогМодулей.Существует() Тогда
		Файлы = НайтиФайлы(КаталогМодулей.ПолноеИмя, "*.os");
		Для Каждого Файл Из Файлы Цикл
			СтандартнаяОбработка = Ложь;
			Попытка
				ДобавитьМодуль(Файл.ПолноеИмя, Файл.ИмяБезРасширения);				
			Исключение
				СтандартнаяОбработка = Истина;
			КонецПопытки;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКлассЕслиРанееНеДобавляли(ПутьФайла, ИмяКласса)
	
	КлассУжеЕсть = Ложь;
	Попытка
		Объект = Новый(ИмяКласса);
		КлассУжеЕсть = Истина;
	Исключение
		СообщениеОшибки = ОписаниеОшибки();
		ИскомаяОшибка = СтрШаблон("Конструктор не найден (%1)", ИмяКласса);
		КлассУжеЕсть = СтрНайти(СообщениеОшибки, ИскомаяОшибка) = 0;
	КонецПопытки;
	Если Не КлассУжеЕсть Тогда
		
		ДобавитьКласс(ПутьФайла, ИмяКласса);
		
	КонецЕсли;
КонецПроцедуры
