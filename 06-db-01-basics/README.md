# Домашнее задание к занятию "6.1. Типы и структура СУБД"

## Задача 1

Архитектор ПО решил проконсультироваться у вас, какой тип БД 
лучше выбрать для хранения определенных данных.

Он вам предоставил следующие типы сущностей, которые нужно будет хранить в БД:

- Электронные чеки в json виде
  * Документо-ориентированная - классичиское применение документов json
- Склады и автомобильные дороги для логистической компании
  * Сетевая - иерархическая с множеством узлов, но в зависимости от целей, можно и графовую использовать т.к. графы обычно используют для решения структурных задачь в теории СМО
- Генеалогические деревья
  * Иерархическая- класические деревья с одним родителем
- Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации
  * Ключ-значение тоже класическая постановка задачи для данного типа
- Отношения клиент-покупка для интернет-магазина
  * Реляционная - так как тут отношение М:М и много таблиц

Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор.

## Задача 2

Вы создали распределенное высоконагруженное приложение и хотите классифицировать его согласно 
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система, если 
(каждый пункт - это отдельная реализация вашей системы и для каждого пункта надо привести классификацию):

- Данные записываются на все узлы с задержкой до часа (асинхронная запись)
  * CA(CAP)/PC-EL(PACELC) 
- При сетевых сбоях, система может разделиться на 2 раздельных кластера
  * PA(CAP)/PA-EL(PACELC)
- Система может не прислать корректный ответ или сбросить соединение
  * PC(CAP)/PA-EC(PACELC)

А согласно PACELC-теореме, как бы вы классифицировали данные реализации?

## Задача 3

Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?

- Принцыпы BASE и ACID сочетаться не могут. По ACID - данные согласованные, а по BASE - могут быть неверные данные после деградации части узлов, следовательно они противоречат друг другу.

## Задача 4

Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни
- реакция на истечение таймаута

Вы слышали о key-value хранилище, которое имеет механизм [Pub/Sub](https://habr.com/ru/post/278237/). 
Что это за система? Какие минусы выбора данной системы?

 - Это система `Redis`  
Минусы: 
    - Довольно новая система и постоянно находятся в стадии усовершенствований
    - Размер БД ограничен доступной памятью, нужно следить за достатончостью памяти
    - Отсутсвие поддержки  языка SQL, скрипты на LUA
    - Нет сегментации на пользователей или группы пользователей. Отсутствует контроль доступа
    - При отказе сервера все данные с последней синхронизации с диском будут утеряны
---