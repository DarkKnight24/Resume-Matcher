'use client';

import { useTranslations } from 'next-intl';
import BackgroundContainer from '@/components/common/background-container';
import FileUpload from '@/components/common/file-upload';

export default function UploadResume() {
	const t = useTranslations('UploadResume');
	return (
		<BackgroundContainer innerClassName="justify-start pt-16">
			<div className="w-full max-w-md mx-auto flex flex-col items-center gap-6">
				<h1 className="text-4xl font-bold text-center text-white mb-6">
					{t('title')}
				</h1>
				<p className="text-center text-gray-300 mb-8">
					{t('description')}
				</p>
				<div className="w-full">
					<FileUpload />
				</div>
			</div>
		</BackgroundContainer>
	);
}
