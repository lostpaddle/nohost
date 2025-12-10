# 基于轻量的 Node.js 16 Alpine 镜像（Nohost 对 Node 版本要求 >=12，16 更稳定）
FROM node:16.20.2-alpine3.18

npm i -g @nohost/server --registry=https://r.npm.taobao.org

n2 start
