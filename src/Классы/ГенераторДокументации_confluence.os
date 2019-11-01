///////////////////////////////////////////////////////////////////////////////
//
// Служебный класс генерации документации в формате confluence
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////////////////

#Использовать confluence

Перем Шаблоны;

Перем АнализироватьТолькоПотомковПодсистемы;

Перем ПодключениеConfluence;
Перем ПространствоConflunece;
Перем КорневаяСтраницаConflunece;

Перем СимволыЗамены;
Перем ОбновлятьИзмененныеСтраницы;
Перем ПараметрыПодключения;

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

#Область ГенерацияДанных

Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки) Экспорт

	Возврат ПомощникГенерацииДокументации.СформироватьОписаниеМодуляПоШаблонам(ДанныеМодуля, Шаблоны, СимволыЗамены);
	
КонецФункции

Функция ДокументацияКонстанты(МассивКонстант, Ошибки) Экспорт
	
	Возврат ПомощникГенерацииДокументации.СформироватьОписаниеКонстантПоШаблонам(МассивКонстант, Шаблоны, СимволыЗамены);

КонецФункции

#КонецОбласти

#Область Публикация

Функция ОпубликоватьРаздел(Раздел, ОбъектыРаздела, ОшибкиПубликации) Экспорт
	
	Если НЕ ПроверкаВозможностиПубликации(Раздел, ОшибкиПубликации) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;

	Успешно = Истина;
	
	ИдентификаторРаздела = СоздатьРаздел(Раздел, ОшибкиПубликации);
		
	Для Каждого НоваяСтраница Из ОбъектыРаздела Цикл
				
		Попытка
			
			ИмяСтраницы = "Программный интерфейс: " + НоваяСтраница.Имя;
			Сообщить("Создана страница " + ИмяСтраницы);
			Confluence.СоздатьСтраницуИлиОбновить(
								ПодключениеConfluence,
								ПространствоConflunece, 
								ИмяСтраницы,
								СокрЛП(НоваяСтраница.Содержимое),
								ИдентификаторРаздела, 
								ОбновлятьИзмененныеСтраницы);
			
		Исключение
			
			ОшибкиПубликации.Добавить("Ошибка создания страницы '" + НоваяСтраница.Имя + "': " + ОписаниеОшибки());
			Успешно = Ложь;
			Прервать;

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

	НастройкиConfluence = НастройкиСтенда.Настройка("AutodocGen\НастройкиConluence");
	Если ЗначениеЗаполнено(НастройкиConfluence) Тогда
		
		Попытка
			
			ПодключениеConfluence = confluence.ОписаниеПодключения(НастройкиConfluence["АдресСервера"], НастройкиConfluence["Пользователь"], НастройкиConfluence["Пароль"]);
			ПространствоConflunece = НастройкиConfluence["Пространство"];
			КорневаяСтраницаConflunece = НастройкиConfluence["КорневаяСтраница"];
			АнализироватьТолькоПотомковПодсистемы = Строка(НастройкиConfluence["АнализироватьТолькоПотомковПодсистемы"]);

			Если НЕ (ЗначениеЗаполнено(ПространствоConflunece) И ЗначениеЗаполнено(ПространствоConflunece)) Тогда

				ВызватьИсключение "Некорректные настройки пространства и корневой страницы confluence";
				
			КонецЕсли;
			
			Шаблоны = ПомощникГенерацииДокументации.ЗагрузитьШаблоны(НастройкиConfluence["ПутьКШаблонам"], "Шаблоны_conluence.json");
	
		Исключение
			
			ТекстОшибки = "Ошибка установки соединения с сервером confluence: " + ОписаниеОшибки();

		КонецПопытки;

	Иначе

		ТекстОшибки = "Отсутствуют настройки подключения к confluence";
		
	КонецЕсли;

	Возврат ТекстОшибки;
	
КонецФункции

#КонецОбласти

#Область Служебные

Функция ПроверкаВозможностиПубликации(Раздел, ОшибкиПубликации)

	Если ПараметрыПодключения = Неопределено Тогда
		
		Идентификатор = Confluence.НайтиСтраницуПоИмени(ПодключениеConfluence, ПространствоConflunece, КорневаяСтраницаConflunece);

		ПараметрыПодключения = Новый Структура();
		ПараметрыПодключения.Вставить("ИдентификаторКорняСтраницы", Идентификатор);
		
	КонецЕсли;
	
	Если ПустаяСтрока(ПараметрыПодключения.ИдентификаторКорняСтраницы) Тогда
		
		ОшибкиПубликации.Добавить("В пространстве отсутствует корневая страница документации '" + КорневаяСтраницаConflunece + "'");
		Возврат Ложь;
		
	КонецЕсли;
	
	Если СоздатьРаздел(Раздел, ОшибкиПубликации) = Неопределено Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;

КонецФункции

Функция СоздатьРаздел(Раздел, ОшибкиПубликации)
	
	Если Раздел = Неопределено Тогда
		
		Возврат ПараметрыПодключения.ИдентификаторКорняСтраницы;

	КонецЕсли;
	
	ИдентификаторСтраницы = Confluence.НайтиСтраницуПоИмени(ПодключениеConfluence, ПространствоConflunece, Раздел.Имя);
						
	Если ПустаяСтрока(ИдентификаторСтраницы) Тогда
					
		Если Раздел.Родитель = Неопределено
			ИЛИ ЗначениеЗаполнено(Раздел.Родитель.Идентификатор) Тогда
			
			Попытка 
				
				Сообщить("Создан раздел " + Раздел.Имя);
				ИдентификаторСозданнойСтраницы = Confluence.СоздатьСтраницу(
													ПодключениеConfluence,
													ПространствоConflunece,
													Раздел.Имя,
													Раздел.Содержимое,
													?(Раздел.Родитель = Неопределено, 
														ПараметрыПодключения.ИдентификаторКорняСтраницы, 
														Раздел.Родитель.Идентификатор));
				
			Исключение
				
				ОшибкиПубликации.Добавить("Ошибка создания страницы '" + Раздел.Имя + "': " + ОписаниеОшибки());
				
				Возврат Неопределено;
				
			КонецПопытки;
			
			Раздел.Идентификатор = ИдентификаторСозданнойСтраницы;
			
		Иначе
			
			ОшибкиПубликации.Добавить("Создание страницы подсистемы '" + Раздел.Имя + "' невозможно, т.к. не создана страница раздела");
			Возврат Неопределено;
			
		КонецЕсли;				
		
	Иначе
		
		Раздел.Идентификатор = ИдентификаторСтраницы;
		
	КонецЕсли;
	
	Возврат ИдентификаторСтраницы;
	
КонецФункции

#КонецОбласти

///////////////////////////////////////////////////////////////////

СимволыЗамены = Новый Соответствие;
СимволыЗамены.Вставить("\", "\\");
СимволыЗамены.Вставить("&", "&amp;");
СимволыЗамены.Вставить("<", "&lt;");
СимволыЗамены.Вставить(">", "&gt;");
СимволыЗамены.Вставить(Символ(8211), "&ndash;");
СимволыЗамены.Вставить(Символ(8212), "&mdash;");
СимволыЗамены.Вставить(Символы.ПС, "\n");
СимволыЗамены.Вставить(Символ(13), "\n");
СимволыЗамены.Вставить(Символы.Таб, "    ");

ОбновлятьИзмененныеСтраницы = Истина; // в параметры выносить не будем... пока
