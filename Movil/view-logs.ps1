# Script para ver logs de React Native/Expo
Write-Host "=== Ver Logs de React Native ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Presiona Ctrl+C para detener" -ForegroundColor Yellow
Write-Host "2. Busca lÃ­neas con 'ERROR', 'Exception', o 'String.*Boolean'" -ForegroundColor Yellow
Write-Host ""

# Verificar si adb estÃ¡ disponible
$adbAvailable = Get-Command adb -ErrorAction SilentlyContinue
if ($adbAvailable) {
    Write-Host "Iniciando logcat de Android..." -ForegroundColor Green
    adb logcat | Select-String -Pattern "error|Error|ERROR|exception|Exception|String.*Boolean|ReactNativeJS" -CaseSensitive:$false
} else {
    Write-Host "ADB no encontrado. AsegÃºrate de tener Android SDK instalado." -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternativa: Abre la terminal de Expo y busca el error en rojo." -ForegroundColor Yellow
}
