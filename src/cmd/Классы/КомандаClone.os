﻿перем Лог;

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("u storage-user", "", "пользователь хранилища конфигурации")
				.ТСтрока()
				.ВОкружении("GITSYNC_STORAGE_USER")
				.ПоУмолчанию("Администратор");
	Команда.Опция("p storage-pwd", "", "пароль пользователя хранилища конфигурации")
				.ТСтрока()
				.ВОкружении("GITSYNC_STORAGE_PASSWORD GITSYNC_STORAGE_PWD");

	Команда.Аргумент("PATH", "", "Путь к хранилищу конфигурации 1С.")
				.ТСтрока()
				.ВОкружении("GITSYNC_STORAGE_PATH");
	Команда.Аргумент("URL", "", "Адрес удаленного репозитория GIT.")
				.ТСтрока()
				.ВОкружении("GITSYNC_REPO_URL");
	Команда.Аргумент("WORKDIR", "", "Каталог исходников внутри локальной копии git-репозитария.")
				.ТСтрока()
				.ВОкружении("GITSYNC_WORKDIR")
				.Обязательный(Ложь)
				.ПоУмолчанию(ТекущийКаталог());

	ПараметрыПриложения.ВыполнитьПодпискуПриРегистрацииКомандыПриложения(Команда);

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ПутьКХранилищу			= Команда.ЗначениеАргумента("PATH");
	КаталогРабочейКопии		= Команда.ЗначениеАргумента("WORKDIR");
	URLРепозитория			= Команда.ЗначениеАргумента("URL");

	ПользовательХранилища		= Команда.ЗначениеОпции("--storage-user");
	ПарольПользователяХранилища	= Команда.ЗначениеОпции("--storage-pwd");

	Лог.Отладка("КаталогРабочейКопии: %1", КаталогРабочейКопии);

	Если ПустаяСтрока(URLРепозитория) Тогда

		ВызватьИсключение "Не указан URL репозитария";

	КонецЕсли;

	КлонироватьРепозитарий(КаталогРабочейКопии, URLРепозитория);

	МассивФайлов = НайтиФайлы(КаталогРабочейКопии, "src");
	КаталогИсходников = КаталогРабочейКопии;
	Если МассивФайлов.Количество() > 0  Тогда
		КаталогИсходников = МассивФайлов[0].ПолноеИмя;
	КонецЕсли;
		
	ОбщиеПараметры = ПараметрыПриложения.Параметры();
	МенеджерПлагинов = ОбщиеПараметры.УправлениеПлагинами;
	
	ИндексПлагинов = МенеджерПлагинов.ПолучитьИндексПлагинов();

	Распаковщик = Новый МенеджерСинхронизации();
	Распаковщик.ВерсияПлатформы(ОбщиеПараметры.ВерсияПлатформы)
			   .ДоменПочтыПоУмолчанию(ОбщиеПараметры.ДоменПочты)
			   .ИсполняемыйФайлГит(ОбщиеПараметры.ПутьКГит)
			   .ПодпискиНаСобытия(ИндексПлагинов)
			   .ПараметрыПодписокНаСобытия(Команда.ПараметрыКоманды())
			   .УровеньЛога(ПараметрыПриложения.УровеньЛога())
			   .АвторизацияВХранилищеКонфигурации(ПользовательХранилища, ПарольПользователяХранилища);

	Распаковщик.НаполнитьКаталогРабочейКопииСлужебнымиДанными(КаталогИсходников, ПутьКХранилищу);

	Лог.Информация("Клонирование завершено");

КонецПроцедуры // ВыполнитьКоманду

// Выполняет клонирование удаленного репо
//
Процедура КлонироватьРепозитарий(Знач КаталогЛокальнойКопии, Знач URLРепозитария)

	Лог.Отладка("Каталог локальной копии: <%1>", КаталогЛокальнойКопии);
	Лог.Отладка("URL репозитория: <%1>", URLРепозитария);
	
	ГитРепозиторий = Новый ГитРепозиторий;

	ОбщиеПараметры = ПараметрыПриложения.Параметры();

	Если ЗначениеЗаполнено(ОбщиеПараметры.ПутьКГит) Тогда
		ГитРепозиторий.УстановитьПутьКГит(ОбщиеПараметры.ПутьКГит);
	КонецЕсли;

	ГитРепозиторий.УстановитьРабочийКаталог(КаталогЛокальнойКопии);
	ГитРепозиторий.КлонироватьРепозиторий(URLРепозитария, КаталогЛокальнойКопии);

КонецПроцедуры

Лог = ПараметрыПриложения.Лог();