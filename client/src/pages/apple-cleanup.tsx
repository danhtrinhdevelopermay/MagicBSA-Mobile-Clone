import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import ApplePhotosEditor from "@/components/ui/apple-photos-editor";
import { useToast } from "@/hooks/use-toast";

export default function AppleCleanup() {
  const [, setLocation] = useLocation();
  const [imageUrl, setImageUrl] = useState<string>("");
  const { toast } = useToast();

  useEffect(() => {
    // Get the image from sessionStorage
    const storedFileData = sessionStorage.getItem('uploadedFile');
    if (storedFileData) {
      const { fileName, fileType, fileData } = JSON.parse(storedFileData);
      // Convert base64 back to blob URL
      const byteCharacters = atob(fileData);
      const byteNumbers = new Array(byteCharacters.length);
      for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
      }
      const byteArray = new Uint8Array(byteNumbers);
      const blob = new Blob([byteArray], { type: fileType });
      const url = URL.createObjectURL(blob);
      setImageUrl(url);
    } else {
      // No image data, redirect to home
      setLocation('/');
    }

    // Cleanup function to revoke object URL
    return () => {
      if (imageUrl) {
        URL.revokeObjectURL(imageUrl);
      }
    };
  }, [setLocation]);

  const handleCancel = () => {
    setLocation('/');
  };

  const handleDone = async (processedImageBlob: Blob) => {
    try {
      // Create download link
      const url = URL.createObjectURL(processedImageBlob);
      const link = document.createElement('a');
      link.href = url;
      link.download = 'cleaned-image.png';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      toast({
        title: "Image Saved",
        description: "Your cleaned image has been downloaded successfully!",
      });

      // Navigate back after a short delay
      setTimeout(() => {
        setLocation('/');
      }, 1000);
    } catch (error) {
      toast({
        title: "Save Failed",
        description: "Failed to save the processed image",
        variant: "destructive",
      });
    }
  };

  const handleMaskComplete = (maskData: ImageData) => {
    console.log('Mask data ready:', maskData);
    // Here you would typically send the mask data to your AI cleanup API
  };

  if (!imageUrl) {
    return (
      <div className="h-screen bg-black flex items-center justify-center">
        <div className="text-white text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-400 mx-auto mb-4"></div>
          <p>Loading image...</p>
        </div>
      </div>
    );
  }

  return (
    <ApplePhotosEditor
      imageUrl={imageUrl}
      onCancel={handleCancel}
      onDone={handleDone}
      onMaskComplete={handleMaskComplete}
    />
  );
}