import React, { useRef } from 'react';
import { Button } from './button';
import { cn } from '@/lib/utils';

interface FileUploadTriggerProps {
  onFileSelect: (file: File) => void;
  accept?: string;
  children: React.ReactNode;
  className?: string;
}

export default function FileUploadTrigger({
  onFileSelect,
  accept = "image/*",
  children,
  className
}: FileUploadTriggerProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      onFileSelect(file);
    }
    // Reset input value to allow selecting the same file again
    event.target.value = '';
  };

  return (
    <>
      <Button
        onClick={handleClick}
        className={cn(className)}
        type="button"
      >
        {children}
      </Button>
      <input
        ref={fileInputRef}
        type="file"
        accept={accept}
        onChange={handleFileChange}
        className="hidden"
      />
    </>
  );
}