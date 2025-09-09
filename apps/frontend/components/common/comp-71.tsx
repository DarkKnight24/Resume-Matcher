import { useId } from 'react';
import { useTranslations } from 'next-intl';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';

export default function Component() {
  const id = useId();
  const t = useTranslations('Comp71');
  return (
    <div className="group relative">
      <Label
        htmlFor={id}
        className="bg-background text-foreground absolute start-1 top-0 z-10 block -translate-y-1/2 px-2 text-xs font-medium group-has-disabled:opacity-50"
      >
        {t('label')}
      </Label>
      <Textarea id={id} />
    </div>
  );
}
