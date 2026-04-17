# Windows 兼容性参考

在 Windows 环境下执行 lark-cli 命令时需要注意的差异。当命令执行异常时查阅此文档。

## Shell 差异

Windows 上 Cola 可能使用 Git Bash、cmd.exe 或 PowerShell，不同 shell 对命令语法的支持不同：

| 语法 | Git Bash | cmd.exe | PowerShell |
|------|----------|---------|------------|
| `nohup ... &` | 支持 | 不支持，用 `start /b` | 不支持，用 `Start-Process` |
| `&&` 链式 | 支持 | 部分支持 | 用 `;` |
| `$(...)` 子命令 | 支持 | 不支持 | 支持 |
| `2>/dev/null` | 支持 | 用 `2>nul` | 用 `2>$null` |
| `which` | 支持 | 不存在 | 用 `Get-Command` |

**最稳妥的做法**：逐条执行命令（不链式），`lark-cli` 本身的命令跨平台通用。

## 命令找不到的常见原因

npm 全局安装后，可执行文件在以下位置：

- `%APPDATA%\npm\lark-cli.cmd`
- `C:\Progra~1\nodejs\npm.cmd`
- `C:\Progra~1\nodejs\npx.cmd`

如果 `lark-cli` 或 `npm` 找不到，先试完整路径。如果完整路径也不行，通常是 PATH 没刷新——重启 Cola 即可。

## bat 文件中转方案

当命令执行后没有任何输出返回时（cmd.exe 下偶发），可以用 bat 文件捕获输出：

```bat
@echo off
echo STARTED > %TEMP%\lark-out.txt
call lark-cli doctor >> %TEMP%\lark-out.txt 2>&1
echo __DONE__ >> %TEMP%\lark-out.txt
```

执行 bat 文件后，用文件读取工具读 `%TEMP%\lark-out.txt` 获取结果。

## cmd.exe 下的后台运行

`nohup` 和 `&` 在 cmd.exe 下不可用，替代方案：

```cmd
start /b lark-cli config init --new > %TEMP%\lark-init-output.txt 2>&1
timeout /t 5 >nul
type %TEMP%\lark-init-output.txt
```

`start /b` 在后台启动进程，`timeout /t 5` 等待 5 秒，`type` 读取输出文件。
