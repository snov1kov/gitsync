﻿
Перем Лог;

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("t timer", 0, "таймер повторения синхронизации, сек")
					.ТЧисло()
					.ВОкружении("GITSYNC_ALL_TIMER");

	Команда.Опция("u storage-user", "", "пользователь хранилища конфигурации")
					.ТСтрока()
					.ВОкружении("GITSYNC_STORAGE_USER")
					.ПоУмолчанию("Администратор");

	Команда.Опция("p storage-pwd", "", "пароль пользователя хранилища конфигурации")
					.ТСтрока()
					.ВОкружении("GITSYNC_STORAGE_PASSWORD GITSYNC_STORAGE_PWD");
	
	Команда.Аргумент("CONFIG", "", "путь к файлу настройки пакетной синхронизации")
					.ТСтрока()
					.ВОкружении("GITSYNC_ALL_CONFIG")
					.Обязательный(Ложь)
					.ПоУмолчанию(ОбъединитьПути(ТекущийКаталог(), ПараметрыПриложения.ИмяФайлаНастройкиПакетнойСинхронизации()));

	ПараметрыПриложения.ВыполнитьПодпискуПриРегистрацииКомандыПриложения(Команда);
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	Лог.Информация("Начало выполнение команды <all>");
	
	ПутьКФайлуНастроек			= Команда.ЗначениеАргумента("CONFIG");
	
	ПользовательХранилища		= Команда.ЗначениеОпции("storage-user");
	ПарольПользователяХранилища	= Команда.ЗначениеОпции("storage-pwd");

	ИнтервалПовторенияСинхронизации = Команда.ЗначениеОпции("timer");

	ФайлНастроек = Новый Файл(ПутьКФайлуНастроек);
	Если Не ФайлНастроек.Существует() Тогда
		ВызватьИсключение Новый ИнформацияОбОшибке(СтрШаблон("Файл настроек <%1> не найден", ФайлНастроек.ПолноеИмя), "Работа приложения остановлена");
	КонецЕсли;

	ОбщиеПараметры = ПараметрыПриложения.Параметры();

	ПакетнаяСинхронизация = Новый ПакетнаяСинхронизация();
	ПакетнаяСинхронизация.УстановитьНастройки(ФайлНастроек);
	ПакетнаяСинхронизация.ТаймерПовторения(ИнтервалПовторенияСинхронизации)
				.КаталогПлагинов(ПараметрыПриложения.КаталогПлагинов())
				.ФайлВключенныхПлагинов(ПараметрыПриложения.ФайлВключенныхПлагинов())
				.ВерсияПлатформы(ОбщиеПараметры.ВерсияПлатформы)
				.ДоменПочтыПоУмолчанию(ОбщиеПараметры.ДоменПочты)
				.ИсполняемыйФайлГит(ОбщиеПараметры.ПутьКГит)
				.УровеньЛога(ПараметрыПриложения.УровеньЛога())
				.РежимУдаленияВременныхФайлов(Истина)
				.АвторизацияВХранилищеКонфигурации(ПользовательХранилища, ПарольПользователяХранилища);

	ПакетнаяСинхронизация.ВыполнитьСинхронизацию();
	
	Лог.Информация("Завершено выполнение команды <all>");
		
КонецПроцедуры

Лог = ПараметрыПриложения.Лог();