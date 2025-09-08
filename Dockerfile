# 多阶段构建 - Builder 阶段
FROM node:18-bullseye AS builder

# 设置工作目录
WORKDIR /app

# 安装 uv (Python 包管理器)
# UV_PYTHON_PREFERENCE="managed" 允许 uv 管理其自己的 Python 版本，
# 如果系统 Python 不满足 pyproject.toml 的要求。
ENV UV_PYTHON_PREFERENCE="managed"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --bin-dir /usr/local/bin

# 复制依赖文件以利用 Docker 缓存
# 根目录依赖
COPY package*.json ./
# 前端依赖
COPY apps/frontend/package*.json ./apps/frontend/
# 后端依赖
COPY apps/backend/pyproject.toml ./apps/backend/
# 如果 uv 使用 lockfile (例如 uv.lock)，也应该复制它
# COPY apps/backend/uv.lock ./apps/backend/ # 如果存在

# Create temporary .env files for build-time commands
RUN test -f apps/backend/.env.sample && cp apps/backend/.env.sample apps/backend/.env || echo "backend .env.sample not found, skipping"
RUN test -f apps/frontend/.env.sample && cp apps/frontend/.env.sample apps/frontend/.env || echo "frontend .env.sample not found, skipping"

# 安装根目录依赖
RUN npm ci

# 安装后端依赖
RUN cd apps/backend && uv sync

# 安装前端依赖
RUN cd apps/frontend && npm ci

# 复制整个项目源代码用于构建
# .dockerignore 文件应该被用来排除不必要的文件和目录
COPY . .

# 构建前端应用
RUN npm run build --workspace=apps/frontend


# 多阶段构建 - Runner 阶段
FROM node:18-bullseye AS runner

# 设置工作目录
WORKDIR /app

# 安装 uv
ENV UV_PYTHON_PREFERENCE="managed"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --bin-dir /usr/local/bin

# 复制后端依赖定义
COPY apps/backend/pyproject.toml ./apps/backend/
# COPY apps/backend/uv.lock ./apps/backend/ # 如果存在

# 安装后端生产依赖
RUN cd apps/backend && uv sync --no-dev --frozen

# 从 builder 阶段复制前端构建产物
COPY --from=builder /app/apps/frontend/.next ./apps/frontend/.next
COPY --from=builder /app/apps/frontend/public ./apps/frontend/public
COPY --from=builder /app/apps/frontend/next.config.ts ./apps/frontend/next.config.ts
COPY --from=builder /app/apps/frontend/package.json ./apps/frontend/package.json

# 从 builder 阶段复制后端应用源代码
COPY --from=builder /app/apps/backend/app ./apps/backend/app

# 从 builder 阶段复制 .env 文件 (如果它们是构建产物的一部分或被修改过)
# 或者，最好在运行时通过环境变量提供这些
# 为了简单起见，这里我们从 builder 复制它们
COPY --from=builder /app/.env ./
COPY --from=builder /app/apps/backend/.env ./apps/backend/.env
# 前端的 .env 通常在构建时使用，运行时可能不需要，除非有运行时配置
# COPY --from=builder /app/apps/frontend/.env ./apps/frontend/.env

# 复制启动脚本
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 暴露端口
EXPOSE 3000 8000

# Ollama 服务:
# 在生产环境中，Ollama 应作为独立服务运行。
# 请通过环境变量 (例如, BACKEND__LLM_PROVIDER__OLLAMA__BASE_URL) 将 Ollama 服务的地址注入到此容器中。
# 本 Dockerfile 不包含 Ollama 的安装或模型拉取步骤。

# 设置启动命令
CMD ["/app/start.sh"]