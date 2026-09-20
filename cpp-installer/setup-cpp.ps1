<#
.SYNOPSIS
    Portable C++20 environment installer
    MSYS2 (UCRT64) + GCC + GDB + CMake + Ninja

.NOTES
    - 可重複執行 (idempotent)，換電腦直接再跑一次即可
    - 記錄檔：%TEMP%\cpp-setup.log
    - 建議用同資料夾的 setup-cpp.bat 啟動（雙擊即可）
#>
[CmdletBinding()]
param(
    [switch]$NoPause   # 從自動化流程執行時，不要在結尾等待 Enter
)

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$ErrorActionPreference = 'Stop'

# ============================================================
# 設定（要改路徑或套件，只需要改這一區）
# ============================================================
$MsysRoot = 'C:\msys64'
$Bash     = Join-Path $MsysRoot 'usr\bin\bash.exe'
$Bin      = Join-Path $MsysRoot 'ucrt64\bin'
$Packages = @(
    'mingw-w64-ucrt-x86_64-toolchain',   # gcc / g++ / gdb / binutils / mingw32-make
    'mingw-w64-ucrt-x86_64-cmake',
    'mingw-w64-ucrt-x86_64-ninja'
)
$Tools   = @('gcc', 'g++', 'gdb', 'cmake', 'ninja')
$LogFile = Join-Path $env:TEMP 'cpp-setup.log'

# ============================================================
# 共用函式
# ============================================================
function Write-Step([string]$Message) { Write-Host ''; Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message)   { Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Fail([string]$Message) { Write-Host "[錯誤] $Message" -ForegroundColor Red }

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 執行外部程式：輸出直接顯示，非 0 結束碼時丟出例外（除非 -AllowFail）
function Invoke-Native {
    param(
        [string]$File,
        [string[]]$Arguments,
        [switch]$AllowFail
    )
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'   # 避免 stderr 文字被當成終止錯誤
    try {
        & $File @Arguments | Out-Host
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prev
    }
    if ($code -ne 0 -and -not $AllowFail) {
        throw "指令失敗 (exit code $code)：$File $($Arguments -join ' ')"
    }
    return $code
}

# 網路不穩時自動重試
function Invoke-WithRetry {
    param(
        [scriptblock]$Action,
        [int]$Times = 3,
        [int]$DelaySeconds = 5
    )
    for ($i = 1; $i -le $Times; $i++) {
        try { & $Action; return }
        catch {
            if ($i -eq $Times) { throw }
            Write-Warning "第 $i 次失敗：$($_.Exception.Message)，$DelaySeconds 秒後重試..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Format-PathEntry([string]$Path) {
    return $Path.Trim().TrimEnd('\').ToLowerInvariant()
}

# 把資料夾放到「使用者 PATH」最前面：
#   - 完整比對（不會被 C:\msys64\ucrt64\bin2 之類的路徑誤判為已存在）
#   - 保留原本的 %VAR% 寫法，並維持 REG_EXPAND_SZ
#   - 修改前先備份
# 回傳 $true = 有修改，$false = 本來就在最前面
function Add-UserPath {
    param([Parameter(Mandatory)][string]$Dir)

    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
    if (-not $key) { throw '無法開啟 HKCU\Environment' }
    try {
        $raw = [string]$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        $target = Format-PathEntry $Dir
        $others = @($raw -split ';' | Where-Object { $_.Trim() -ne '' -and (Format-PathEntry $_) -ne $target })
        $newValue = (@($Dir) + $others) -join ';'

        if ($newValue -eq $raw) { return $false }

        $backup = Join-Path $env:TEMP ('user-path-backup-{0:yyyyMMdd-HHmmss}.txt' -f (Get-Date))
        Set-Content -LiteralPath $backup -Value $raw -Encoding UTF8
        Write-Host "    原本的使用者 PATH 已備份：$backup"

        $key.SetValue('Path', $newValue, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        return $true
    }
    finally {
        $key.Close()
    }
}

# 通知其他程式（檔案總管等）環境變數有變更
function Send-EnvironmentChange {
    [Environment]::SetEnvironmentVariable('CPP_SETUP_REFRESH', '1', 'User')
    [Environment]::SetEnvironmentVariable('CPP_SETUP_REFRESH', $null, 'User')
}

# 逐一檢查工具：存在、可執行、而且實際會執行到 MSYS2 版本
# 回傳失敗的工具名稱
function Test-Toolchain {
    $failed = @()
    foreach ($tool in $Tools) {
        $found = @(Get-Command $tool -All -ErrorAction SilentlyContinue)
        if ($found.Count -eq 0) {
            Write-Fail "$tool：在 PATH 中找不到"
            $failed += $tool
            continue
        }

        $exe = $found[0].Source
        $prev = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try { $ver = [string](& $exe --version 2>&1 | Select-Object -First 1) }
        finally { $ErrorActionPreference = $prev }

        Write-Ok "$tool  ->  $ver"
        if (-not $exe.StartsWith($Bin, [StringComparison]::OrdinalIgnoreCase)) {
            Write-Warning "$tool 目前會先執行 $exe，而不是 MSYS2 版本 ($Bin)。請檢查系統 PATH 是否有其他編譯器排在前面。"
        }
    }
    return $failed
}

function Assert-Output([string]$Exe) {
    $out = (& $Exe) -join "`n"
    if ($LASTEXITCODE -ne 0 -or $out -notmatch 'C\+\+20 OK: 46') {
        throw "執行 $Exe 的結果不符預期：$out"
    }
    Write-Ok $out
}

# 真的編譯並執行 C++20 程式：先用 g++ 直接編，再用 CMake + Ninja 編
function Test-CppBuild {
    # 用 C:\Windows\Temp（純英文路徑），避免中文使用者名稱造成編譯器讀路徑出問題
    $dir = Join-Path $env:SystemRoot ('Temp\cpp20_test_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir | Out-Null
    try {
        $mainCpp = @'
#include <concepts>
#include <iostream>

template <std::integral T>
T add(T a, T b) { return a + b; }

int main() {
    std::cout << "C++20 OK: " << add(20, 26) << '\n';
}
'@
        $cmakeLists = @'
cmake_minimum_required(VERSION 3.20)
project(cpp20_test CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_executable(cpp20_test main.cpp)
'@
        Set-Content -LiteralPath (Join-Path $dir 'main.cpp') -Value $mainCpp -Encoding ASCII
        Set-Content -LiteralPath (Join-Path $dir 'CMakeLists.txt') -Value $cmakeLists -Encoding ASCII

        Write-Step 'C++20 編譯測試 (g++)'
        $direct = Join-Path $dir 'direct.exe'
        $null = Invoke-Native 'g++' @('-std=c++20', '-Wall', '-Wextra', (Join-Path $dir 'main.cpp'), '-o', $direct)
        Assert-Output $direct

        Write-Step 'CMake + Ninja 建置測試'
        $build = Join-Path $dir 'build'
        $null = Invoke-Native 'cmake' @('-S', $dir, '-B', $build, '-G', 'Ninja', "-DCMAKE_CXX_COMPILER=$Bin\g++.exe")
        $null = Invoke-Native 'cmake' @('--build', $build)
        Assert-Output (Join-Path $build 'cpp20_test.exe')
    }
    finally {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================
# 需要系統管理員權限：不是的話，自動以管理員身分重新啟動自己
# （用 Windows 身分檢查，不依賴 net session / Server 服務）
# ============================================================
if (-not (Test-Admin)) {
    Write-Host '需要系統管理員權限，正在要求提升 (UAC)...'
    try {
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath)
        )
        exit 0
    }
    catch {
        Write-Fail '無法取得系統管理員權限（是否在 UAC 視窗按了「否」？）'
        if (-not $NoPause) { Read-Host '按 Enter 關閉視窗' | Out-Null }
        exit 1
    }
}

# ============================================================
# 主流程
# ============================================================
$exitCode = 0
try {
    try { Start-Transcript -Path $LogFile -Force | Out-Null } catch { }

    Write-Host ''
    Write-Host '==========================================' -ForegroundColor Cyan
    Write-Host '   Portable C++20 Environment Installer'
    Write-Host '   MSYS2 + UCRT64 + GCC + CMake + Ninja'
    Write-Host '==========================================' -ForegroundColor Cyan

    # [1/6] winget
    Write-Step '[1/6] 檢查 winget'
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw '找不到 winget。請先到 Microsoft Store 更新「應用程式安裝程式」(App Installer)。'
    }
    Write-Ok 'winget 可用'

    # [2/6] MSYS2
    Write-Step '[2/6] 檢查 / 安裝 MSYS2'
    if (Test-Path -LiteralPath $Bash) {
        Write-Ok "已找到 MSYS2：$MsysRoot"
    }
    else {
        $null = Invoke-Native 'winget' @('install', '-e', '--id', 'MSYS2.MSYS2', '--accept-package-agreements', '--accept-source-agreements')
        if (-not (Test-Path -LiteralPath $Bash)) {
            throw "MSYS2 安裝完成後仍找不到 $Bash（可能被安裝到其他資料夾，請修改腳本上方的 `$MsysRoot）"
        }
        Write-Ok 'MSYS2 安裝完成'
    }

    # [3/6] 更新 MSYS2（第一次更新核心後 pacman 可能中途結束，屬正常現象，所以第一次不當成錯誤）
    Write-Step '[3/6] 更新 MSYS2（會執行兩次）'
    $null = Invoke-Native $Bash @('-lc', 'pacman -Syu --noconfirm') -AllowFail
    Invoke-WithRetry { $null = Invoke-Native $Bash @('-lc', 'pacman -Syu --noconfirm') }
    Write-Ok 'MSYS2 已是最新'

    # [4/6] 開發工具
    Write-Step '[4/6] 安裝 GCC / GDB / CMake / Ninja'
    $pkgList = $Packages -join ' '
    Invoke-WithRetry { $null = Invoke-Native $Bash @('-lc', "pacman -S --needed --noconfirm $pkgList") }
    Write-Ok '開發工具安裝完成'

    # [5/6] PATH
    Write-Step '[5/6] 設定使用者 PATH'
    if (Add-UserPath -Dir $Bin) { Write-Ok "已將 $Bin 放到 PATH 最前面" }
    else { Write-Ok "PATH 已包含（且在最前面）：$Bin" }
    Send-EnvironmentChange

    # 模擬「新開的終端機」會拿到的 PATH（系統 + 使用者），這樣驗證的才是真正寫進去的設定
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"

    # [6/6] 驗證
    Write-Step '[6/6] 驗證環境'
    $failed = @(Test-Toolchain)
    if ($failed.Count -gt 0) { throw "下列工具驗證失敗：$($failed -join ', ')" }
    Test-CppBuild

    Write-Host ''
    Write-Host '==========================================' -ForegroundColor Green
    Write-Host '   安裝完成！' -ForegroundColor Green
    Write-Host '==========================================' -ForegroundColor Green
    Write-Host '請重新開啟 CMD / PowerShell / VS Code，新的 PATH 才會生效。'
    Write-Host "記錄檔：$LogFile"
}
catch {
    Write-Host ''
    Write-Fail $_.Exception.Message
    Write-Host "詳細記錄：$LogFile"
    Write-Host '修正問題後可直接重新執行本腳本（可重複執行）。'
    $exitCode = 1
}
finally {
    try { Stop-Transcript | Out-Null } catch { }
    if (-not $NoPause) { Read-Host '按 Enter 關閉視窗' | Out-Null }
}
exit $exitCode
