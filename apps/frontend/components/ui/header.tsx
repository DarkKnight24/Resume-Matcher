'use client'
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import LanguageSwitcher from '@/components/common/language-switcher';

const Header = () => {
	const t = useTranslations('Header');
	return (
		<header className="sticky top-0 left-0 z-50 w-full bg-white shadow-sm">
			<div className="container mx-auto flex h-16 items-center justify-between px-6">
				{/* Logo */}
				<Link href="/" className="text-xl font-bold text-gray-900">
					{t('logo')}
				</Link>

				{/* Navigation */}
				<nav className="flex items-center space-x-6">
					<Link href="/overview" className="text-sm text-gray-600 hover:text-gray-900">
						{t('overview')}
					</Link>
					<Link href="/signup" className="text-sm text-gray-600 hover:text-gray-900">
						{t('signup')}
					</Link>
					<Link href="/blog" className="text-sm text-gray-600 hover:text-gray-900">
						{t('blog')}
					</Link>
					<Link
						href="/buy"
						className="rounded-md bg-teal-400 px-4 py-2 text-sm font-medium text-white transition-colors duration-200 hover:bg-teal-500"
					>
						{t('buySpazioBianco')}
					</Link>
					<LanguageSwitcher />
				</nav>
			</div>
		</header>
	);
};

export default Header;
