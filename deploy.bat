@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set SERVER=47.96.41.243
set PORT=3000
set ADMIN_KEY=sanguoq_admin_2024
set FLEX_SDK=/d/BaiduNetdiskDownload/flex_home

echo ============================================
echo   三国Q战 - 一键编译部署 v2.1.1
echo ============================================

echo [1/4] 编译 SWF...
bash -c "java -jar %FLEX_SDK%/lib/mxmlc.jar +flexlib=%FLEX_SDK%/frameworks -compiler.source-path=. -default-size=770,500 -target-player=32.0 -static-link-runtime-shared-libraries=true -external-library-path=air_stubs.swc -- game/Sanguo4399.as" 2>&1 | findstr /C:"字节" /C:"错误" /C:"Error"
if %ERRORLEVEL% NEQ 0 (
    echo 编译失败!
    pause & exit /b 1
)
copy /y game\Sanguo4399.swf main.swf >nul
echo 编译成功: main.swf

echo [2/4] 上传服务端代码...
bash -c "B64=\$(base64 -w0 server/start_fixed.js); rm -f /tmp/dep_chunk_*; split -b 4800 -d --additional-suffix=.chunk <(echo \"\$B64\") /tmp/dep_chunk_; for f in /tmp/dep_chunk_*.chunk; do CHUNK=\$(cat \"\$f\"); curl -s -m 8 -X POST \"http://%SERVER%:%PORT%/api/admin/exec\" -H \"Content-Type: application/json\" -d \"{\\\"key\\\":\\\"%ADMIN_KEY%\\\",\\\"cmd\\\":\\\"echo '\$CHUNK' >> /opt/dep.b64 \\&\\& echo ok\\\"}\" | grep -q '\"ok\":true' || exit 1; done && echo ALL_CHUNKS_OK"
if %ERRORLEVEL% NEQ 0 ( echo 服务端上传失败! & pause & exit /b 1 )

echo [3/4] 部署服务端...
bash -c "curl -s -m 10 -X POST \"http://%SERVER%:%PORT%/api/admin/exec\" -H \"Content-Type: application/json\" -d '{\"key\":\"%ADMIN_KEY%\",\"cmd\":\"base64 -d /opt/dep.b64 > /opt/start_fixed_new.js && node --check /opt/start_fixed_new.js && cp /opt/start_fixed.js /opt/start_fixed_bak.js && mv /opt/start_fixed_new.js /opt/start_fixed.js && rm /opt/dep.b64 && printf \\\"#!/bin/bash\\\\nsleep 2\\\\npkill -f node.*start_fixed\\\\nsleep 1\\\\ncd /opt && nohup node start_fixed.js > server.log 2>&1 &\\\\necho OK\\\\n\\\" > /opt/restart.sh && chmod +x /opt/restart.sh && nohup bash /opt/restart.sh > /tmp/rlog 2>&1 & echo DEPLOYED\"}'"

echo [4/4] 上传客户端 SWF...
bash -c "B64=\$(base64 -w0 main.swf); rm -f /tmp/swf_dep_chunk_*; split -b 4800 -d --additional-suffix=.chunk <(echo \"\$B64\") /tmp/swf_dep_chunk_; for f in /tmp/swf_dep_chunk_*.chunk; do CHUNK=\$(cat \"\$f\"); curl -s -m 8 -X POST \"http://%SERVER%:%PORT%/api/admin/exec\" -H \"Content-Type: application/json\" -d \"{\\\"key\\\":\\\"%ADMIN_KEY%\\\",\\\"cmd\\\":\\\"echo '\$CHUNK' >> /opt/client/swf_dep.b64 \\&\\& echo ok\\\"}\" | grep -q '\"ok\":true' || exit 1; done && echo ALL_SWF_CHUNKS_OK && curl -s -m 5 -X POST \"http://%SERVER%:%PORT%/api/admin/exec\" -H \"Content-Type: application/json\" -d '{\"key\":\"%ADMIN_KEY%\",\"cmd\":\"base64 -d /opt/client/swf_dep.b64 > /opt/client/main.swf && rm /opt/client/swf_dep.b64 && ls -la /opt/client/main.swf\"}'"

echo.
echo ============================================
echo   部署完成! 服务端将自动重启
echo   客户端下次启动时自动获取更新
echo ============================================
pause
