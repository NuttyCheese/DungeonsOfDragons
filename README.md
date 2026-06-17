# Dungeons of Dragons

iOS приложение для игры в Dungeons & Dragons, предоставляющее справочную информацию о монстрах, заклинаниях и инструмент для броска кубиков.

## Основные возможности

- **Монстры** — каталог монстров с детальной информацией, фильтрацией и поиском
- **Заклинания** — справочник заклинаний с описаниями и характеристиками
- **Кубики** — 3D симулятор броска кубиков (d4, d6, d8, d10, d12, d20, d100) с физикой
- **Избранное** — сохранение любимых монстров и заклинаний
- **Настройки** — выбор темы оформления (светлая/тёмная/системная)

## Архитектура

Проект использует архитектуру **MVC (Model-View-Controller)**:

- **Model** — модели данных (`MonsterModel`, `SpellModel`) и бизнес-логика
- **View** — UI компоненты (ячейки, кастомные view)
- **Controller** — ViewControllers, управляющие отображением и взаимодействием

### Основные компоненты

- `BaseViewController` — базовый контроллер с градиентным фоном и поддержкой тем
- `DesignManager` — менеджер тем оформления (Singleton)
- `DataSourceRemote` — сетевой слой для загрузки данных
- `FavoritesManager` — управление избранным через UserDefaults
- `DiceViewController` — 3D симулятор кубиков на SceneKit

## Технологии

- Swift
- UIKit
- SceneKit (для 3D кубиков)
- URLSession (для сетевых запросов)
- UserDefaults (для хранения избранного)
- Diffable Data Source (для коллекций)

[![Смотреть видео](https://img.shields.io/badge/▶-Смотреть_видео-red)](https://github.com/user-attachments/assets/e5ffb53d-4a8e-4008-8f4e-f83413744525)

[![Смотреть видео](https://img.shields.io/badge/▶-Смотреть_видео-red)](https://github.com/user-attachments/assets/72ad1ac6-2bdf-417e-8cb0-8dff36f3ec5a)
