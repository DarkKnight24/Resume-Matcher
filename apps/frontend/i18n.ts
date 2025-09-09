// apps/frontend/i18n.ts
import { getRequestConfig } from 'next-intl/server';

// A list of all locales that are supported
const locales = ['en', 'zh'] as const;

export default getRequestConfig(async ({ locale }) => {
  const timestamp = new Date().toISOString();
  const resolvedLocale = locale && locales.includes(locale as any) ? locale : 'en';

  try {
    const messages = (await import(`./messages/${resolvedLocale}.json`)).default;
    return {
      locale: resolvedLocale as string,
      messages,
    };
  } catch (error) {
    console.error(`[${timestamp}] Error loading messages for locale ${locale}:`, error);
    throw error;
  }
});

console.log('=== End i18n.ts Loading ===');
