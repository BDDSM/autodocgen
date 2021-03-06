///////////////////////////////////////////////////////////////////////////////
//
// Служебный класс генерации документации в формате markdown
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

Перем Шаблоны;

Перем КаталогПубликацииДокументации;
Перем АнализироватьТолькоПотомковПодсистемы Экспорт;

Перем СимволыЗамены;

///////////////////////////////////////////////////////////////////
// СТАНДАРТНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////

#Область ГенерацияДанных

// ДокументацияПоМодулю
//
// Параметры:
//   ДанныеМодуля - Структура - Описание модуля, структура содержащая массив описаний методов, см. ГенераторДокументации.ОписаниеМетода
//   Ошибки - Массив - Коллекция ошибок генерации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Строка - Текст документации по модулю, если пустая строка, публикация не выполняется
//
Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки) Экспорт
	
	ПомощникГенерацииДокументации.УстановитьПараметрыГенерации(Новый Структура("ЭкранироватьКавычки", Ложь));
	
	Строки = ПомощникГенерацииДокументации.СформироватьОписаниеМодуляПоШаблонам(ДанныеМодуля, Шаблоны, СимволыЗамены);

	Если Строки.Количество() Тогда

		Строки.Вставить(0, СтрШаблон(Шаблоны.ШаблонНачалоСтраницы, ДанныеМодуля.Имя));
		Строки.Добавить(Шаблоны.ШаблонКонецСтраницы);

	КонецЕсли;

	Возврат СтрСоединить(Строки, Символы.ПС);

КонецФункции

// ДокументацияКонстанты
//
// Параметры:
//   МассивКонстант - Массив - Массив структур описаний констант
//						Имя - Имя константы
//						Тип - Тип значения константы
//						Описание - Описание константы
//						Подсистема - Описание подсистем, которой принадлежит константа. см ГенераторДокументации.ПолучитьСтруктуруПодсистем
//   Ошибки - Массив - Коллекция ошибок генерации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Строка - Текст документации по модулю, если пустая строка, публикация не выполняется
//
Функция ДокументацияКонстанты(МассивКонстант, Ошибки) Экспорт

	ПомощникГенерацииДокументации.УстановитьПараметрыГенерации(Новый Структура("ЭкранироватьКавычки", Ложь));
	
	Строки = ПомощникГенерацииДокументации.СформироватьОписаниеКонстантПоШаблонам(МассивКонстант, Шаблоны, СимволыЗамены);

	Если Строки.Количество() Тогда

		Строки.Вставить(0, СтрШаблон(Шаблоны.ШаблонНачалоСтраницы, "Константы"));
		Строки.Добавить(Шаблоны.ШаблонКонецСтраницы);

	КонецЕсли;

	Возврат СтрСоединить(Строки, Символы.ПС);

КонецФункции

#КонецОбласти

#Область Публикация

// ОпубликоватьРаздел
//
// Параметры:
//   Раздел - СтрокаТаблицыЗначений - Описание публикуемого раздела
//				* Имя - Имя страницы/раздела
//				* Родитель - Родитель страницы, ссылку на строку этой же таблицы
//				* Содержимое - Содержимое страницы
//				* Идентификатор - Служебное поле, можно использовать при публикации
//   ОбъектыРаздела - СтрокаТаблицыЗначений - Массив описаний объектов раздела
//				* Имя - Имя объекта
//				* Родитель - Родитель страницы, ссылку на строку этой же таблицы
//				* Содержимое - Содержимое страницы
//				* Идентификатор - Служебное поле, можно использовать при публикации
//   ОшибкиПубликации - Массив - Коллекция ошибок публикации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Булево - Признак успешности
//
Функция ОпубликоватьРаздел(Раздел, ОбъектыРаздела, ОшибкиПубликации) Экспорт

	Если НЕ ПомощникГенерацииДокументации.ПроверкаВозможностиПубликацииВКаталог(КаталогПубликацииДокументации, Раздел, ОшибкиПубликации) Тогда

		Возврат Ложь;

	КонецЕсли;

	Успешно = Истина;

	Каталог = ПомощникГенерацииДокументации.СоздатьКаталогРаздела(КаталогПубликацииДокументации, Раздел);

	Для Каждого НоваяСтраница Из ОбъектыРаздела Цикл

		Попытка

			ПутьКСтранице = ОбъединитьПути(Каталог, НоваяСтраница.Имя) + ".markdown ";
			ОбщегоНазначения.ЗаписатьФайл(ПутьКСтранице, СокрЛП(НоваяСтраница.Содержимое));

		Исключение

			ОшибкиПубликации.Добавить("Ошибка создания страницы '" + НоваяСтраница.Имя + "': " + ОписаниеОшибки());
			Успешно = Ложь;

		КонецПопытки;

	КонецЦикла;

	Возврат Успешно;

КонецФункции

Функция ПрефиксИмени(ТипСтраницы) Экспорт
	
	Если ТипСтраницы = "Модуль" Тогда
		
		Возврат "Программный интерфейс. ";
		
	Иначе
		
		Возврат "";
		
	КонецЕсли;

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

	Настройки = НастройкиСтенда.Настройка("AutodocGen\НастройкиMarkdown");
	Если ЗначениеЗаполнено(Настройки) Тогда

		Шаблоны = ПомощникГенерацииДокументации.ЗагрузитьШаблоны(Настройки["ПутьКШаблонам"], "Шаблоны_Markdown.json");
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

СимволыЗамены = Новый Соответствие();
СимволыЗамены.Вставить(Символы.ПС, "<br/>");
СимволыЗамены.Вставить(Символ(13), "<br/>");