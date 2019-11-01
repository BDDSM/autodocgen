///////////////////////////////////////////////////////////////////////////////
//
// Служебный класс генерации документации в формате html
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////////////////

Перем Шаблоны;

Перем КаталогПубликацииДокументации;
Перем АнализироватьТолькоПотомковПодсистемы;

Перем СимволыЗамены;

///////////////////////////////////////////////////////////////////
// СТАНДАРТНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////

#Область ГенерацияДанных

Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки) Экспорт
	
	Текст = ПомощникГенерацииДокументации.СформироватьОписаниеМодуляПоШаблонам(ДанныеМодуля, Шаблоны);
	
	Если Не ПустаяСтрока(Текст) Тогда
		
		Текст = Шаблоны.ШаблонНачалоСтраницы + Текст + Шаблоны.ШаблонКонецСтраницы;
		
	КонецЕсли;

	Возврат Текст;

КонецФункции

Функция ДокументацияКонстанты(МассивКонстант, Ошибки) Экспорт

	Текст = ПомощникГенерацииДокументации.СформироватьОписаниеКонстантПоШаблонам(МассивКонстант, Шаблоны);

	Если Не ПустаяСтрока(Текст) Тогда
		
		Текст = Шаблоны.ШаблонНачалоСтраницы + Текст + Шаблоны.ШаблонКонецСтраницы;
		
	КонецЕсли;

	Возврат Текст;
	
КонецФункции

#КонецОбласти

#Область Публикация

Функция ОпубликоватьРаздел(Раздел, ОбъектыРаздела, ОшибкиПубликации) Экспорт
	
	Если НЕ ПомощникГенерацииДокументации.ПроверкаВозможностиПубликацииВКаталог(КаталогПубликацииДокументации, Раздел, ОшибкиПубликации) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Успешно = Истина;
	
	Каталог = ПомощникГенерацииДокументации.СоздатьКаталогРаздела(КаталогПубликацииДокументации, Раздел);

	Для Каждого НоваяСтраница Из ОбъектыРаздела Цикл

		ИмяСтраницы = "Программный интерфейс. " + НоваяСтраница.Имя;

		Попытка
			
			ПутьКСтранице = ОбъединитьПути(Каталог, НоваяСтраница.Имя) + ".html";
			ОбщегоНазначения.ЗаписатьФайл(ПутьКСтранице, СокрЛП(НоваяСтраница.Содержимое));

		Исключение

			ОшибкиПубликации.Добавить("Ошибка создания страницы '" + НоваяСтраница.Имя + "': " + ОписаниеОшибки());
			Успешно = Ложь;

		КонецПопытки;
		
	КонецЦикла;

	Возврат Успешно;

КонецФункции

#КонецОбласти

#Область Настройки

// Производит чтение настроект из конфигурационного файла и сохраяет их в свойствах объекта
//
// Параметры:
//	 НастройкиСтенда - Объект.НастройкиСтенда - Объект, содержащий информацию конфигурационного файла
//
// Возвращаемое значение:
//	Строка - описание возникших ошибок
Функция ПрочитатьНастройки(НастройкиСтенда) Экспорт

	ТекстОшибки = "";

	НастройкиHTML = НастройкиСтенда.Настройка("AutodocGen\НастройкиHTML");
	Если ЗначениеЗаполнено(НастройкиHTML) Тогда

		Шаблоны = ПомощникГенерацииДокументации.ЗагрузитьШаблоны(НастройкиHTML["ПутьКШаблонам"], "Шаблоны_HTML.json");
		КаталогПубликацииДокументации = НастройкиHTML["КаталогПубликации"];
		АнализироватьТолькоПотомковПодсистемы = Строка(НастройкиHTML["АнализироватьТолькоПотомковПодсистемы"]);

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
СимволыЗамены.Вставить("\", "\\");
СимволыЗамены.Вставить("&", "&amp;");
СимволыЗамены.Вставить("<", "&lt;");
СимволыЗамены.Вставить(">", "&gt;");
СимволыЗамены.Вставить(Символ(8211), "&ndash;");
СимволыЗамены.Вставить(Символ(8212), "&mdash;");
СимволыЗамены.Вставить(Символы.ПС, "<br/>");
СимволыЗамены.Вставить(Символ(13), "<br/>");
СимволыЗамены.Вставить(Символы.Таб, "    ");

