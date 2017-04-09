Приклад на базі [PostgreSQL](https://www.postgresql.org/)

для функціонування потрібно створити БД
```bash
psql -U postgres

DROP DATABASE exchanger;
CREATE DATABASE exchanger;
\c exchanger;
CREATE TABLE rates (date date PRIMARY KEY, rate NUMERIC(8, 4));
\q
```
розпакувати проект
встановити рубі та бандлер
```
gem install bundler
```
доставити геми
```
bundle install
```
Запустити виконання тестів
```
rspec
```
(перший раз вони пройдуть помилками але заповнять БД значеннями).
Повторне виконання пройде без помилок.

Виконувати скрипти можна командами:
```
ruby Exchanger.exchange(100, '2017-04-07')
ruby Exchanger.exchange(100, ['2017-04-07', '2017-04-02', '2017-02-07', '2017-04-07'])
```
або у консолі **irb**
```
irb
require_relative 'exchanger.rb'
Exchanger.exchange(100, '2017-04-07')
Exchanger.exchange(100, ['2017-04-07', '2017-04-02', '2017-02-07', '2017-04-07'])
```
