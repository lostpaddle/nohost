# 构建阶段
FROM node:14-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖配置文件（先复制package.json以利用Docker缓存）
COPY package.json package-lock.json ./
COPY packages/admin/package.json ./packages/admin/
COPY packages/gateway/package.json ./packages/gateway/
COPY packages/tools/router/package.json ./packages/tools/router/

# 安装所有依赖（包括开发依赖）
RUN npm ci

# 复制项目源代码
COPY . .

# 执行构建命令（根据package.json中的scripts，构建前端资源）
RUN npm run dist

# 生产阶段
FROM node:14-alpine

# 设置环境变量
ENV NODE_ENV=production
WORKDIR /app

# 复制依赖配置文件
COPY package.json package-lock.json ./
COPY packages/admin/package.json ./packages/admin/
COPY packages/gateway/package.json ./packages/gateway/
COPY packages/tools/router/package.json ./packages/tools/router/

# 仅安装生产依赖
RUN npm ci --production

# 从构建阶段复制构建结果和必要的源代码
COPY --from=builder /app/public ./public
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/bin ./bin
COPY --from=builder /app/index.js ./index.js

# 暴露项目端口（package.json中定义的port为8080）
EXPOSE 8080

# 启动命令（根据bin配置，使用nohost入口文件）
CMD ["node", "bin/nohost.js", "run"]
