'use client';

import { useLocale } from 'next-intl';
import { useRouter } from 'next/navigation';
import { ChangeEvent } from 'react';

export default function LanguageSwitcher() {
  const router = useRouter();
  const locale = useLocale();

  const handleChange = (e: ChangeEvent<HTMLSelectElement>) => {
    const newLocale = e.target.value;
    const currentPath = window.location.pathname;
    // Remove the current locale from the path and add the new one
    const newPath = currentPath.replace(/^\/[a-z]{2}\//, `/${newLocale}/`);
    router.replace(newPath);
  };

  return (
    <select
      className="bg-transparent text-white border border-gray-600 rounded-md p-2"
      value={locale}
      onChange={handleChange}
    >
      <option value="en" className="text-black">English</option>
      <option value="zh" className="text-black">中文</option>
    </select>
  );
}