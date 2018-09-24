///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с методами общего назначения для приложения
//
///////////////////////////////////////////////////////////////////////////////

#Использовать tempfiles
#Использовать 1commands

Функция КаталогИсходныхФайлов(ПараметрыКоманды, Знач Приложение) Экспорт
	
	КаталогИсходныхФайлов = ПараметрыКоманды["КаталогИсходныхФайлов"];
	Если НЕ ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Не указан каталог исходных файлов");
		Возврат Неопределено;
		
	Иначе
		
		Файл = Новый Файл(КаталогИсходныхФайлов);
		Если Не Файл.Существует() ИЛИ НЕ Файл.ЭтоКаталог() Тогда
			
			Приложение.ЗавершитьРаботуПриложенияСОшибкой(СтрШаблон("Каталог репозитория '%1' несуществует или это файл", КаталогИсходныхФайлов));
			Возврат Неопределено;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат КаталогИсходныхФайлов;
	
КонецФункции 

Функция ПрочитатьНастройкиСтенда(КаталогИсходныхФайлов, ПараметрыКоманды, Знач Приложение) Экспорт
	
	АдресКонфигурационногоФайла = ПараметрыКоманды["-config"];
	Если НЕ ЗначениеЗаполнено(АдресКонфигурационногоФайла) Тогда
		
		АдресКонфигурационногоФайла = КаталогИсходныхФайлов;
		
	КонецЕсли;

	НастройкиСтенда = Новый НастройкиСтенда();
	НастройкиСтенда.Инициализация(АдресКонфигурационногоФайла);
	
	Если НастройкиСтенда.ЭтоНовый() Тогда
		
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Конфигурационный файл не обнаружен");
		Возврат Неопределено;
		
	КонецЕсли;
	
	Возврат НастройкиСтенда;
	
КонецФункции

Функция ПрочитатьНастройкиАнализаИзменений(НастройкиСтенда, КаталогИсходныхФайлов, ПараметрыКоманды, Знач Приложение) Экспорт
	
	НастройкиАнализаИзменений = Новый Структура();
	НастройкиАнализаИзменений.Вставить("Анализировать", ПараметрыКоманды["-git"]);
	Если НастройкиАнализаИзменений.Анализировать = Неопределено Тогда
		
		НастройкиАнализаИзменений.Анализировать = Ложь;
		
	КонецЕсли;
	
	Если НЕ НастройкиАнализаИзменений.Анализировать Тогда

		Возврат НастройкиАнализаИзменений;

	КонецЕсли;

	ПоследняяВерсия = НастройкиСтенда.Настройка("AutodocGen\ПоследнийОбработанныйКоммит");
	Если НЕ ЗначениеЗаполнено(ПоследняяВерсия) Тогда
		
		ПоследняяВерсия = "";
		
	КонецЕсли;

	ФайлЛог = ВременныеФайлы.НовоеИмяФайла("log");
	КомандаGit = Новый КомандныйФайл();
	КомандаGit.ДобавитьКоманду(СтрШаблон("cd /d ""%1""", КаталогИсходныхФайлов));	
	КомандаGit.ДобавитьКоманду("git pull origin");
	КомандаGit.ДобавитьКоманду(СтрШаблон(
				"git log %1 --pretty=short --name-only --no-merges --all -- *CommonModule/*/Module.txt* *CommonModules/*/Module.bsl* *Ext/ManagerModule.bsl* > ""%2"" ", 
					?(Не ПустаяСтрока(ПоследняяВерсия), ПоследняяВерсия + "..HEAD", "--after='2001-01-01'"), 
					ФайлЛог));				
	
	КодВозврата = КомандаGit.Исполнить();
	ВыводКоманды = КомандаGit.ПолучитьВывод();
	
	Если КодВозврата <> 0 Тогда
		
		ТекстОшибки = СтрШаблон("Ошибка получения изменений: код ошибки %1%2Вывод%3", КодВозврата, Символы.ПС, ВыводКоманды);
		Приложение.ЗавершитьРаботуПриложенияСОшибкой(ТекстОшибки);
		Возврат Неопределено;
		
	КонецЕсли;

	СоставЛога = РазобратьФайлЛога(ФайлЛог, КаталогИсходныхФайлов);

	НастройкиАнализаИзменений.Вставить("ИзмененныеФайлы", СоставЛога.ИзмененныеФайлы);
	НастройкиАнализаИзменений.Вставить("ИдентификаторКоммита", СоставЛога.ИдентификаторКоммита);
	
	Возврат НастройкиАнализаИзменений;
	
КонецФункции

Функция ПолучитьГенераторДокументации(НастройкиСтенда, ПараметрыКоманды, Знач Приложение) Экспорт
	
	Формат = ПараметрыКоманды["-format"];
	Если НЕ ЗначениеЗаполнено(Формат) Тогда
		
		Формат = "confluence";
		
	КонецЕсли;
	
	Попытка 
		
		ГенераторДокументации = Новый ("ГенераторДокументации_" + Формат);
		
	Исключение

		ТекстОшибки = СтрШаблон("Ошибка создания объект генератора документации в формате '%1': %2", Формат, ОписаниеОшибки());
		Приложение.ЗавершитьРаботуПриложенияСОшибкой(ТекстОшибки);
		Возврат Неопределено;

	КонецПопытки;
	
	ТекстОшибки = ГенераторДокументации.ПрочитатьНастройки(НастройкиСтенда);
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		
		ТекстОшибки = СтрШаблон("Ошибка чтения настроек генератора документации в формате '%1': %2", Формат, ТекстОшибки);
		Приложение.ЗавершитьРаботуПриложенияСОшибкой(ТекстОшибки);
		Возврат Неопределено;
		
	КонецЕсли;

	Возврат ГенераторДокументации;

КонецФункции

Функция ПолучитьПарсерКонфигурации(Знач ПарсерКонфигурации = Неопределено) Экспорт
	
	Если ПарсерКонфигурации = Неопределено Тогда
		
		ПарсерКонфигурации = Новый РазборСтруктурыКонфигурации1С;
		
	КонецЕсли;
	
	Возврат ПарсерКонфигурации;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////

Функция РазобратьФайлЛога(ИмяФайла, КаталогРепозитория)
	
	Файл = Новый ТекстовыйДокумент;
	Файл.Прочитать(ИмяФайла, "UTF-8");
	КолСтрок = Файл.КоличествоСтрок();
	
	ИдентификаторКоммита = "";
	ИзмененныеФайлы = Новый Массив;
	
	Для Ит = 1 По КолСтрок Цикл
		
		СтрокаМодуля = Файл.ПолучитьСтроку(Ит);
		Если СтрНачинаетсяС(СтрокаМодуля, "commit") Тогда
			
			Если ПустаяСтрока(ИдентификаторКоммита) Тогда
				
				ИдентификаторКоммита = СокрЛП(Сред(СтрокаМодуля, СтрДлина("commit") + 1));			
				
			КонецЕсли;
			
			Продолжить;
			
		Иначе 
			
			Попытка
				
				ФайлМодуля = Новый Файл(ОбъединитьПути(КаталогРепозитория, СтрокаМодуля));
				
				Если ФайлМодуля.Существует() И НЕ ФайлМодуля.ЭтоКаталог() Тогда
					
					ИзмененныеФайлы.Добавить(НРЕГ(ФайлМодуля.ПолноеИмя));
					
				КонецЕсли;
				
			Исключение
				
				// это мусорные строки
				
			КонецПопытки;
			
		КонецЕсли;		
		
	КонецЦикла;
	
	Возврат Новый Структура("ИзмененныеФайлы, ИдентификаторКоммита", ИзмененныеФайлы, ИдентификаторКоммита);
	
КонецФункции
