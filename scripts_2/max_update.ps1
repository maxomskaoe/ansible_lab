Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# ============================================
# Обновление MAX Messenger
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     ОБНОВЛЕНИЕ MAX MESSENGER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# Переменные
# ============================================
$installer_path = 'C:\Updater\'
$installer_full_path = 'C:\Updater\MAX.msi'
$download_link = 'https://trk.mail.ru/c/h172vv5'

# ============================================
# ШАГ 1: Подготовка папки
# ============================================
Write-Host "[1/5] Подготовка папки для установки..." -ForegroundColor Yellow
if (-not (Test-Path -Path $installer_path -ErrorAction SilentlyContinue)) {
    New-Item -Path $installer_path -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Write-Host "      ✅ Папка создана: $installer_path" -ForegroundColor Green
} else {
    Write-Host "      ✅ Папка уже существует: $installer_path" -ForegroundColor Green
}

# ============================================
# ШАГ 2: Удаление старого установщика
# ============================================
Write-Host "[2/5] Удаление старого установщика..." -ForegroundColor Yellow
Remove-Item $installer_full_path -ErrorAction SilentlyContinue -Force
Write-Host "      ✅ Готово" -ForegroundColor Green

# ============================================
# ШАГ 3: Удаление старой версии программы
# ============================================
Write-Host "[3/5] Удаление старой версии MAX Messenger..." -ForegroundColor Yellow
Write-Host "      ⏳ Это может занять несколько секунд..." -ForegroundColor Gray
winget uninstall --Name Max --nowarn --disable-interactivity --accept-source-agreements --all-versions 2>$null
Write-Host "      ✅ Старая версия удалена (или не была установлена)" -ForegroundColor Green

# ============================================
# ШАГ 4: Скачивание новой версии
# ============================================
Write-Host "[4/5] Скачивание новой версии MAX Messenger..." -ForegroundColor Yellow
Write-Host "      ⏳ Идёт загрузка, это займет несколько минут, пожалуйста, подождите" -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $download_link -OutFile $installer_full_path -ErrorAction Stop
    Write-Host "      ✅ Скачивание завершено" -ForegroundColor Green
} catch {
    Write-Host "      ❌ Ошибка при скачивании: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "     ОБНОВЛЕНИЕ НЕ УДАЛОСЬ" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Проверьте подключение к интернету и попробуйте снова." -ForegroundColor Yellow
    pause
    exit 1
}

# ============================================
# ШАГ 5: Установка
# ============================================
Write-Host "[5/5] Установка MAX Messenger..." -ForegroundColor Yellow
Write-Host "      ⏳ Выполняется установка..." -ForegroundColor Gray

$install = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installer_full_path`" ALLUSERS=2 MSIINSTALLPERUSER=1 /passive /l*v `"$installer_path\max_install.log`"" -Wait -PassThru -NoNewWindow

# ============================================
# Проверка результата
# ============================================
if ($install.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "     ✅ ОБНОВЛЕНИЕ УСПЕШНО ЗАВЕРШЕНО" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "MAX Messenger готов к работе!" -ForegroundColor White
    Write-Host ""
    Write-Host "Окно закроется через 10 секунд..." -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "     ❌ ОШИБКА ОБНОВЛЕНИЯ" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Код ошибки: $($install.ExitCode)" -ForegroundColor Yellow
    Write-Host "Подробности в логе: $installer_path\max_install.log" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Обратитесь к системному администратору." -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

# ============================================
# Завершение
# ============================================
Start-Sleep -Seconds 10
