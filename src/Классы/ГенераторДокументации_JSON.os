///////////////////////////////////////////////////////////////////////////////
//
// Служебный класс генерации документации в формате JSON
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////////////////

Перем КаталогПубликацииДокументации;
Перем АнализироватьТолькоПотомковПодсистемы;

///////////////////////////////////////////////////////////////////
// СТАНДАРТНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////

#Область ГенерацияДанных

Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки) Экспорт
	
	Если НЕ ДанныеМодуля.Методы.Количество() Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	Запись = НовыйЗаписьJSON();
	
	Запись.ЗаписатьНачалоОбъекта();
	
	ТекущийРаздел = Неопределено;
	
	Для Каждого ОписаниеМетода Из ДанныеМодуля.Методы Цикл
		
		Если ТекущийРаздел <> ОписаниеМетода.ИмяРаздела Тогда
			
			Если ТекущийРаздел <> Неопределено Тогда
				
				Запись.ЗаписатьКонецМассива();
				
			КонецЕсли;

			ТекущийРаздел = ОписаниеМетода.ИмяРаздела;
			Запись.ЗаписатьИмяСвойства(ТекущийРаздел);
			Запись.ЗаписатьНачалоМассива();
			
		КонецЕсли;
		
		ОписаниеПараметров = Новый Массив;

		Для Каждого Параметр Из ОписаниеМетода.ПараметрыМетода Цикл
			
			ОписаниеПараметра = Новый Структура;
			ОписаниеПараметра.Вставить("name", Параметр.Имя);
			ОписаниеПараметра.Вставить("required", НЕ ЗначениеЗаполнено(Параметр.ЗначениеПоУмолчанию));
			ОписаниеПараметра.Вставить("type", Параметр.ТипПараметра);
			ОписаниеПараметра.Вставить("description", Параметр.ОписаниеПараметра);
			ОписаниеПараметра.Вставить("default", Параметр.ЗначениеПоУмолчанию);
			
			ОписаниеПараметров.Добавить(ОписаниеПараметра);

		КонецЦикла;

		ЭтоФункция = ОписаниеМетода.ТипБлока = ТипыБлоковМодуля.ЗаголовокФункции;
		Метод = Новый Структура;
		Метод.Вставить("name", ОписаниеМетода.ИмяМетода);
		Метод.Вставить("description", ОписаниеМетода.Описание);
		Метод.Вставить("type", ?(ЭтоФункция, "function", "procedure"));
		Метод.Вставить("public", ОписаниеМетода.Экспортный);
		
		Если ОписаниеПараметров.Количество() Тогда
			Метод.Вставить("parameters", ОписаниеПараметров);
		КонецЕсли;
		
		Если ЭтоФункция Тогда
			ОписаниеВозврат = Новый Структура;
			ОписаниеВозврат.Вставить("type", ОписаниеМетода.ТипВозвращаемогоЗначения);
			ОписаниеВозврат.Вставить("description", ОписаниеМетода.ОписаниеВозвращаемогоЗначения);
			Метод.Вставить("return", ОписаниеВозврат);
		КонецЕсли;

		Если ОписаниеМетода.Примеры.Количество() Тогда
			Метод.Вставить("samples", ОписаниеМетода.Примеры);
		КонецЕсли;
		
		ЗаписатьJSON(Запись, Метод);
		
	КонецЦикла;
	
	Если ТекущийРаздел <> Неопределено Тогда
		Запись.ЗаписатьКонецМассива();
	КонецЕсли;

	Запись.ЗаписатьКонецОбъекта();

	Возврат Запись.Закрыть();

КонецФункции

Функция ДокументацияКонстанты(МассивКонстант, Ошибки) Экспорт
	
	Данные = Новый Массив;
	Иерархия = ПомощникГенерацииДокументации.СобратьИерархиюПоПодсистемам(МассивКонстант);

	Для Каждого ДанныеРаздела Из Иерархия Цикл
		
		ОписаниеРаздела = Новый Структура("name, values", ДанныеРаздела.Ключ, Новый Массив());
		Данные.Добавить(ОписаниеРаздела);

		Для Каждого ДанныеПодсистемы Из ДанныеРаздела.Значение Цикл
			
			ОписаниеПодсистемы = Новый Структура("name, values", ДанныеПодсистемы.Ключ, Новый Массив());
			ОписаниеРаздела.values.Добавить(ОписаниеПодсистемы);

			Для Каждого Константа Из ДанныеПодсистемы.Значение Цикл
				
				ОписаниеПодсистемы.values.Добавить(Новый Структура("name, type, description", 
											Константа.Имя, 
											Константа.Тип, 
											Константа.Описание));
				
			КонецЦикла;
			
		КонецЦикла;

	КонецЦикла;

	Запись = НовыйЗаписьJSON();
	ЗаписатьJSON(Запись, Данные);

	Возврат Запись.Закрыть();

КонецФункции

#КонецОбласти

#Область Публикация

Функция ОпубликоватьРаздел(Раздел, ОбъектыРаздела, ОшибкиПубликации) Экспорт
	
	Если НЕ ПомощникГенерацииДокументации.ПроверкаВозможностиПубликацииВКаталог(КаталогПубликацииДокументации, Раздел, ОшибкиПубликации) Тогда
		Возврат Ложь;	
	КонецЕсли;
	
	Каталог = ПомощникГенерацииДокументации.СоздатьКаталогРаздела(КаталогПубликацииДокументации, Раздел);
	
	Если Раздел <> Неопределено И НЕ ПустаяСтрока(Раздел.Содержимое) Тогда
		
		ИмяФайла = ОбъединитьПути(Каталог, "Description.json");
		ОбщегоНазначения.ЗаписатьФайл(ИмяФайла, Раздел.Содержимое);
		
	КонецЕсли;

	Для Каждого Объект Из ОбъектыРаздела Цикл
		
		ИмяФайла = ОбъединитьПути(Каталог, Объект.Имя + ".json");
		ОбщегоНазначения.ЗаписатьФайл(ИмяФайла, Объект.Содержимое);
		
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти

#Область Настройки

// Производит чтение настроек из конфигурационного файла и сохраняет их в свойствах объекта
//
// Параметры:
//	 НастройкиСтенда - Объект.НастройкиСтенда - Объект, содержащий информацию конфигурационного файла
//
// Возвращаемое значение:
//	Строка - описание возникших ошибок
Функция ПрочитатьНастройки(НастройкиСтенда) Экспорт

	ТекстОшибки = "";

	Настройки = НастройкиСтенда.Настройка("AutodocGen\НастройкиJSON");
	Если ЗначениеЗаполнено(Настройки) Тогда

		КаталогПубликацииДокументации = Настройки["КаталогПубликации"];
		АнализироватьТолькоПотомковПодсистемы = Строка(Настройки["АнализироватьТолькоПотомковПодсистемы"]);

		Если НЕ ЗначениеЗаполнено(КаталогПубликацииДокументации) Тогда

			ТекстОшибки = "Некорректные настройки каталога публикации";

		КонецЕсли;

	Иначе

		ТекстОшибки = "Отсутствуют настройки";

	КонецЕсли;

	Возврат ТекстОшибки;

КонецФункции

#КонецОбласти

Функция НовыйЗаписьJSON()

	Запись = Новый ЗаписьJSON();
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix);
	Запись.УстановитьСтроку(ПараметрыЗаписиJSON);

	Возврат Запись;

КонецФункции