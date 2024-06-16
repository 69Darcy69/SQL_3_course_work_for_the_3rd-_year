База данных должна содержать сведения о следующих объектах:
 Абоненты - фамилия, имя, отчество, адрес, номер телефона, 
абонементная плата (АП), дата уплаты, дата последнего списания 
АП, льготы, состояние счета абонента.
 Телефоны - номер, категория, состояние.
 Заявки на установку - дата регистрации, дата выполнения, номер 
телефона, фамилия и табельный номер монтера, выполнившего 
установку.
 Заявки на ремонт - дата регистрации, номер телефона, дата 
выполнения, фамилия и табельный номер монтера, выполнившего 
ремонт.
 Банковский реестр - сумма, дата поступления, номер телефона, 
номер квитанции.
 Междугородний разговор - дата, время начала, время окончания, 
длительность, исходящий номер телефона, регион входящего 
звонка, стоимость звонках.
 Список регионов – регион, размер платы за 1 минуту разговора.
Выходные документы:
 Извещение о пополнении.
 Детализация междугородних звонков.
 Выписка пополнений из банковского реестра.
Бизнес-правила:
 Каждый абонент имеет только один номер.
 Льготы уменьшают размер абонементной платы.
 Оплата междугородних разговоров производится по тарифу, 
зависящему от расстояния между регионами, внутри одного 
региона звонки между городами бесплатны.
 Оплата междугородних разговоров списывается со счета 
абонента. 
 Абонент в праве использовать станцию для осуществления 
межрегиональных звонков без внесения абонементной платы. 
 Абонементная плата списывается со счета абонента по истечению 
месяца от даты прошлого списания абонементной платы, при 
условии, что на счете достаточно средств.
 При внесении средств на счет абонент получает советующее 
извещение.
 Сведения о заявках на ремонт сохраняются в течение года, 
сведения об установке телефонной станции и сведения о внесении 
средств на счет сохраняются в течении 3 лет.
База данных должна предоставлять следующие возможности для 
абонентов:
 просмотр информации о своем телефоне;
 возможность онлайн пополнения счета;
 просмотр информации о совершенных междугородних звонках;
 просмотр информации о внесении средств на баланс.
Для оператора:
 просмотр информации о телефоне выбранного абонента;
 просмотр информации о совершенных междугородних звонках 
конкретного абонента;
 просмотр информации о внесении средств для выбранного 
абонента;
 просмотр списка монтеров в выбранном городе;
 просмотр активных заявок по установке телефонов;
 просмотр активных заявок по ремонту телефонов;
 добавление новых заявок на ремонт.
Для монтера:
 просмотр назначенных работ;
 возможность поставить отметку о выполнении работы.
Для регистратора:
 добавление новых абонентов;
 добавление новых монтеров;
 возможность обновления льготы абонента.
Реализовать веб-интерфейс для всех категорий пользователей.

