# Resume Matcher 前端国际化 (i18n) 实施计划

本文档旨在为 Resume Matcher 前端应用（基于 Next.js）提供一个详细的国际化（i18n）实施方案。首要目标是增加对简体中文（zh-CN）的支持。

## 1. 分析与技术选型

### 推荐库：`next-intl`

对于基于 Next.js App Router 的项目，**`next-intl`** 是最优选择。

**推荐理由**:

1.  **专为 App Router 设计**: `next-intl` 提供了专门为 Next.js App Router 设计的 APIs 和最佳实践，简化了配置和使用。
2.  **类型安全**: 支持基于翻译文件自动生成类型定义，减少了因 key 拼写错误导致的运行时 bug。
3.  **动态路由集成**: 与 Next.js 的动态路由无缝集成，可以轻松实现 `example.com/en/about` 和 `example.com/zh/about` 这样的 URL 结构。
4.  **服务端组件 (RSC) 支持**: 完美支持服务端组件和客户端组件，无需复杂的 Provider 配置。
5.  **优秀的文档和社区**: 拥有清晰的官方文档和活跃的社区支持。

## 2. 设计方案

### 2.1. 语言包目录结构

我们将在 `apps/frontend` 目录下创建一个 `messages` 文件夹，用于统一存放所有语言的翻译文件。这种结构清晰且易于维护。

```
apps/frontend/
├── app/
├── components/
├── ...
└── messages/
    ├── en.json  // 英文翻译
    └── zh.json  // 中文翻译
```

### 2.2. Next.js App Router 集成

我们将采用基于路径的路由策略（Pathname-based routing），将 locale（语言标识）嵌入 URL 中，例如 `/en/jobs` 或 `/zh/jobs`。

#### 路由和中间件配置

1.  **中间件 (`middleware.ts`)**: 创建一个中间件来处理国际化路由。它的主要职责是解析请求 URL 中的 locale，并将其传递给 `next-intl`。
2.  **动态路由 (`[locale]`)**: 修改现有的目录结构，将所有页面包裹在一个以 `[locale]` 命名的动态路由段下，以便 Next.js 能够识别 URL 中的语言参数。

修改后的目录结构如下：

```
apps/frontend/app/
└── [locale]/
    ├── (default)/
    │   ├── (onboarding)/
    │   │   ├── jobs/
    │   │   │   └── page.tsx
    │   │   └── resume/
    │   └── dashboard/
    └── layout.tsx
    └── page.tsx // 根页面
```

## 3. 实施步骤

### 步骤一：环境设置 (安装依赖)

在 `apps/frontend` 目录下执行以下命令来安装 `next-intl`：

```bash
npm install next-intl
```

### 步骤二：配置

#### 1. 创建 `i18n.ts` 配置文件

在 `apps/frontend` 根目录创建一个 `i18n.ts` 文件，用于配置支持的语言和获取翻译内容。

```typescript
// apps/frontend/i18n.ts
import {getRequestConfig} from 'next-intl/server';
 
export default getRequestConfig(async ({locale}) => ({
  messages: (await import(`./messages/${locale}.json`)).default
}));
```

#### 2. 创建中间件 `middleware.ts`

在 `apps/frontend` 根目录创建 `middleware.ts` 文件，用于处理国际化路由逻辑。

```typescript
// apps/frontend/middleware.ts
import createMiddleware from 'next-intl/middleware';
 
export default createMiddleware({
  // A list of all locales that are supported
  locales: ['en', 'zh'],
 
  // Used when no locale matches
  defaultLocale: 'en'
});
 
export const config = {
  // Match only internationalized pathnames
  matcher: ['/', '/(zh|en)/:path*']
};
```

### 步骤三：创建翻译文件

根据设计的目录结构，创建 `en.json` 和 `zh.json` 文件。

**`apps/frontend/messages/en.json`**:

```json
{
  "ProvideJobDescriptionsPage": {
    "title": "Provide Job Descriptions",
    "description": "Paste up to three job descriptions below. We'll use these to compare against your resume and find the best matches.",
    "loadingText": "Loading input..."
  }
}
```

**`apps/frontend/messages/zh.json`**:

```json
{
  "ProvideJobDescriptionsPage": {
    "title": "提供职位描述",
    "description": "请在下方粘贴最多三个职位描述。我们将使用这些信息与您的简历进行比较，以找出最佳匹配。",
    "loadingText": "正在加载输入框..."
  }
}
```

### 步骤四：代码重构

以 [`apps/frontend/app/(default)/(onboarding)/jobs/page.tsx`](apps/frontend/app/(default)/(onboarding)/jobs/page.tsx) 为例，展示如何替换硬编码字符串。

**修改前的代码**:

```tsx
// apps/frontend/app/[locale]/(default)/(onboarding)/jobs/page.tsx (Original)
import JobDescriptionUploadTextArea from '@/components/jd-upload/text-area';
import BackgroundContainer from '@/components/common/background-container';
import { Suspense } from 'react';

const ProvideJobDescriptionsPage = () => {
	return (
		<BackgroundContainer>
			<div className="flex flex-col items-center justify-center max-w-7xl">
				<h1 className="text-6xl font-bold text-center mb-12 text-white">
					Provide Job Descriptions
				</h1>
				<p className="text-center text-gray-300 text-xl mb-8 max-w-xl mx-auto">
					Paste up to three job descriptions below. We'll use these to compare
					against your resume and find the best matches.
				</p>
				<Suspense fallback={<div>Loading input...</div>}>
					<JobDescriptionUploadTextArea />
				</Suspense>
			</div>
		</BackgroundContainer>
	);
};

export default ProvideJobDescriptionsPage;
```

**修改后的代码 (使用 `next-intl`)**:

```tsx
// apps/frontend/app/[locale]/(default)/(onboarding)/jobs/page.tsx (Refactored)
import JobDescriptionUploadTextArea from '@/components/jd-upload/text-area';
import BackgroundContainer from '@/components/common/background-container';
import { Suspense } from 'react';
import { useTranslations } from 'next-intl';

const ProvideJobDescriptionsPage = () => {
    const t = useTranslations('ProvideJobDescriptionsPage');

	return (
		<BackgroundContainer>
			<div className="flex flex-col items-center justify-center max-w-7xl">
				<h1 className="text-6xl font-bold text-center mb-12 text-white">
					{t('title')}
				</h1>
				<p className="text-center text-gray-300 text-xl mb-8 max-w-xl mx-auto">
					{t('description')}
				</p>
				<Suspense fallback={<div>{t('loadingText')}</div>}>
					<JobDescriptionUploadTextArea />
				</Suspense>
			</div>
		</BackgroundContainer>
	);
};

export default ProvideJobDescriptionsPage;
```

### 步骤五：语言切换器

创建一个客户端组件 (`'use client'`) 用于语言切换。该组件可以使用 `useRouter` 和 `usePathname` from `next-intl/client` 来切换 locale。

**思路**:

1.  创建一个下拉菜单或按钮组，显示支持的语言（如 "English" 和 "中文"）。
2.  当用户选择一门新语言时，使用 `router.replace` 方法，并传入当前的 `pathname` 和新的 `locale` 来刷新页面到新的语言版本 URL。

**示例组件 (`LanguageSwitcher.tsx`)**:

```tsx
'use client';

import { useLocale } from 'next-intl';
import { useRouter, usePathname } from 'next-intl/client';
import { ChangeEvent } from 'react';

export default function LanguageSwitcher() {
  const router = useRouter();
  const pathname = usePathname();
  const locale = useLocale();

  const handleChange = (e: ChangeEvent<HTMLSelectElement>) => {
    const newLocale = e.target.value;
    router.replace(pathname, { locale: newLocale });
  };

  return (
    <select value={locale} onChange={handleChange}>
      <option value="en">English</option>
      <option value="zh">中文</option>
    </select>
  );
}
```

将此组件放入 `Header` 或其他公共布局中即可生效。

---
**计划结束**