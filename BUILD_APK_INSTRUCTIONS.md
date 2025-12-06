# Полная инструкция: Сборка APK и загрузка

## Шаг 1: Установка Android Studio

### 1.1. Скачать Android Studio
1. Открой: https://developer.android.com/studio
2. Нажми "Download Android Studio"
3. Выбери версию для твоего Mac:
   - **Apple Silicon (M1/M2/M3)**: "Mac (Apple Silicon)"
   - **Intel**: "Mac (Intel)"
4. Скачается файл `android-studio-*.dmg` (~1 ГБ)

### 1.2. Установка
1. Открой скачанный `.dmg` файл
2. Перетащи Android Studio в папку Applications
3. Запусти Android Studio из Applications
4. При первом запуске выбери "Standard" installation
5. Дождись загрузки всех компонентов (10-20 минут)

### 1.3. Настройка Android SDK через Android Studio
1. Открой Android Studio
2. Нажми "More Actions" → "SDK Manager" (или Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK)
3. Убедись, что установлены:
   - ✅ Android SDK Platform (последняя версия, например API 34)
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools
4. Нажми "Apply" и дождись установки

### 1.4. Настройка переменных окружения (для терминала)

Открой терминал и выполни:

```bash
# Для zsh (обычно на новых Mac)
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.zshrc

# Примени изменения
source ~/.zshrc
```

Или для bash (старые Mac):
```bash
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.bash_profile
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.bash_profile
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bash_profile
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.bash_profile
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.bash_profile

source ~/.bash_profile
```

### 1.5. Проверка установки
```bash
flutter doctor
```

Должно показать, что Android toolchain настроен.

---

## Шаг 2: Сборка APK

### 2.1. Перейди в папку проекта
```bash
cd /Users/macbookprom1/Desktop/flutter-hw1
```

### 2.2. Собери APK
```bash
flutter build apk --release
```

### 2.3. Найди готовый APK
Файл будет здесь:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Шаг 3: Загрузка APK в Google Drive

### 3.1. Загрузи файл
1. Открой https://drive.google.com
2. Нажми "Создать" (или "+") → "Загрузить файл"
3. Выбери файл: `build/app/outputs/flutter-apk/app-release.apk`
4. Дождись загрузки

### 3.2. Получи ссылку для скачивания
1. Правой кнопкой мыши на файл → "Поделиться" → "Доступ по ссылке"
2. Нажми "Копировать ссылку"
3. Ссылка будет вида: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`

### 3.3. Преобразуй в прямую ссылку на скачивание
Замени ссылку:
- **Было**: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
- **Стало**: `https://drive.google.com/uc?export=download&id=FILE_ID`

Где `FILE_ID` — это длинная строка между `/d/` и `/view` в оригинальной ссылке.

**Пример:**
- Оригинал: `https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing`
- Для скачивания: `https://drive.google.com/uc?export=download&id=1a2b3c4d5e6f7g8h9i0j`

---

## Шаг 4: Добавление ссылки в README.md

### 4.1. Открой README.md
```bash
open README.md
```

Или открой в редакторе кода.

### 4.2. Найди строку с плейсхолдером
Найди строку ~86:
```markdown
- **Актуальная ссылка на APK:**  
  `https://example.com/kototinder-latest.apk` ← **замените на вашу реальную ссылку**
```

### 4.3. Замени на свою ссылку
```markdown
- **Актуальная ссылка на APK:**  
  https://drive.google.com/uc?export=download&id=ТВОЙ_FILE_ID
```

---

## Альтернатива: GitHub Releases

Если у тебя есть GitHub репозиторий:

### 1. Создай релиз
1. Открой свой репозиторий на GitHub
2. Нажми "Releases" → "Create a new release"
3. Заполни:
   - **Tag**: `v1.0.0`
   - **Title**: `Кототиндер v1.0.0`
   - **Description**: Описание приложения
4. Перетащи файл `app-release.apk` в секцию "Attach binaries"
5. Нажми "Publish release"

### 2. Получи ссылку
Ссылка будет вида:
```
https://github.com/ТВОЙ_USERNAME/flutter-hw1/releases/download/v1.0.0/app-release.apk
```

---

## Проверка

После всех шагов проверь:
1. ✅ APK собран и находится в `build/app/outputs/flutter-apk/app-release.apk`
2. ✅ APK загружен в Google Drive/GitHub
3. ✅ Ссылка работает (открой в браузере — должен начаться скачивание)
4. ✅ Ссылка добавлена в README.md

---

## Полезные команды

```bash
# Проверить, что Android SDK настроен
flutter doctor

# Очистить проект перед сборкой
flutter clean

# Собрать APK
flutter build apk --release

# Проверить размер APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

