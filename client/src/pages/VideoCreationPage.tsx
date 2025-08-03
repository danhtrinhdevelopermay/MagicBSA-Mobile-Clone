import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useMutation } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Sparkles, Upload, Send, CheckCircle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";

const videoJobSchema = z.object({
  userEmail: z.string().email("Email không hợp lệ"),
  userName: z.string().min(1, "Tên không được để trống"),
  phoneNumber: z.string().optional(),
  videoStyle: z.string().min(1, "Vui lòng chọn phong cách video"),
  duration: z.string().min(1, "Vui lòng chọn thời lượng"),
  description: z.string().optional(),
  image: z.instanceof(File, { message: "Vui lòng chọn ảnh" })
});

type VideoJobForm = z.infer<typeof videoJobSchema>;

const videoStyles = [
  { value: "cinematic", label: "Điện ảnh - Phong cách Hollywood chuyên nghiệp" },
  { value: "anime", label: "Anime - Phong cách hoạt hình Nhật Bản" },
  { value: "realistic", label: "Thực tế - Chuyển động tự nhiên" },
  { value: "artistic", label: "Nghệ thuật - Phong cách sáng tạo độc đáo" },
  { value: "vintage", label: "Cổ điển - Phong cách retro nostalgic" },
  { value: "futuristic", label: "Tương lai - Phong cách sci-fi hiện đại" }
];

const durations = [
  { value: "3s", label: "3 giây - Nhanh gọn" },
  { value: "5s", label: "5 giây - Chuẩn" },
  { value: "10s", label: "10 giây - Dài" }
];

export default function VideoCreationPage() {
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string>("");
  const [isSubmitted, setIsSubmitted] = useState(false);
  const { toast } = useToast();

  const form = useForm<VideoJobForm>({
    resolver: zodResolver(videoJobSchema),
    defaultValues: {
      userEmail: "",
      userName: "",
      phoneNumber: "",
      videoStyle: "",
      duration: "",
      description: ""
    }
  });

  const mutation = useMutation({
    mutationFn: async (data: VideoJobForm) => {
      const formData = new FormData();
      formData.append('image', data.image);
      formData.append('userEmail', data.userEmail);
      formData.append('userName', data.userName);
      formData.append('phoneNumber', data.phoneNumber || '');
      formData.append('videoStyle', data.videoStyle);
      formData.append('duration', data.duration);
      formData.append('description', data.description || '');

      return await apiRequest('/api/video-jobs', {
        method: 'POST',
        body: formData
      });
    },
    onSuccess: () => {
      setIsSubmitted(true);
      toast({
        title: "Yêu cầu đã được gửi!",
        description: "Chúng tôi sẽ xử lý video và gửi kết quả qua email trong vòng 24-48 giờ.",
      });
    },
    onError: (error) => {
      toast({
        title: "Có lỗi xảy ra",
        description: error.message,
        variant: "destructive",
      });
    }
  });

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedImage(file);
      form.setValue('image', file);
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
    }
  };

  const onSubmit = (data: VideoJobForm) => {
    if (selectedImage) {
      mutation.mutate({ ...data, image: selectedImage });
    }
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center p-4">
        <Card className="w-full max-w-md mx-auto">
          <CardContent className="pt-6">
            <div className="text-center space-y-4">
              <CheckCircle className="mx-auto h-16 w-16 text-green-500" />
              <h2 className="text-2xl font-bold text-green-700 dark:text-green-400">
                Yêu cầu đã được gửi!
              </h2>
              <p className="text-gray-600 dark:text-gray-300">
                Chúng tôi đã nhận được yêu cầu tạo video của bạn. 
                Đội ngũ admin sẽ xử lý và gửi kết quả qua email trong vòng 24-48 giờ.
              </p>
              <Button 
                onClick={() => {
                  setIsSubmitted(false);
                  form.reset();
                  setSelectedImage(null);
                  setPreviewUrl("");
                }}
                className="w-full"
              >
                Tạo video khác
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 dark:from-gray-900 dark:to-gray-800 p-4">
      <div className="max-w-2xl mx-auto">
        <div className="text-center mb-8">
          <div className="flex items-center justify-center mb-4">
            <Sparkles className="h-8 w-8 text-purple-600 mr-2" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
              AI Tạo Video Từ Ảnh
            </h1>
          </div>
          <p className="text-gray-600 dark:text-gray-300">
            Biến ảnh của bạn thành video sống động với công nghệ AI tiên tiến
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Thông tin yêu cầu</CardTitle>
            <CardDescription>
              Vui lòng điền đầy đủ thông tin để chúng tôi có thể xử lý yêu cầu của bạn
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                
                {/* Image Upload */}
                <div className="space-y-2">
                  <FormLabel>Tải ảnh lên *</FormLabel>
                  <div className="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg p-6 text-center">
                    {previewUrl ? (
                      <div className="space-y-4">
                        <img 
                          src={previewUrl} 
                          alt="Preview" 
                          className="mx-auto max-h-64 rounded-lg object-contain"
                        />
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => {
                            setSelectedImage(null);
                            setPreviewUrl("");
                            form.setValue('image', undefined as any);
                          }}
                        >
                          Thay đổi ảnh
                        </Button>
                      </div>
                    ) : (
                      <div className="space-y-4">
                        <Upload className="mx-auto h-12 w-12 text-gray-400" />
                        <div>
                          <label htmlFor="image-upload" className="cursor-pointer">
                            <span className="text-blue-600 hover:text-blue-500">Chọn ảnh</span>
                            <span className="text-gray-500"> hoặc kéo thả vào đây</span>
                          </label>
                          <input
                            id="image-upload"
                            type="file"
                            accept="image/*"
                            onChange={handleImageSelect}
                            className="hidden"
                          />
                        </div>
                        <p className="text-sm text-gray-500">PNG, JPG, WEBP tối đa 10MB</p>
                      </div>
                    )}
                  </div>
                  {form.formState.errors.image && (
                    <p className="text-sm text-red-500">{form.formState.errors.image.message}</p>
                  )}
                </div>

                {/* User Info */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="userName"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Họ và tên *</FormLabel>
                        <FormControl>
                          <Input placeholder="Nguyễn Văn A" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="userEmail"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Email *</FormLabel>
                        <FormControl>
                          <Input placeholder="email@example.com" type="email" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <FormField
                  control={form.control}
                  name="phoneNumber"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Số điện thoại (tùy chọn)</FormLabel>
                      <FormControl>
                        <Input placeholder="0123456789" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {/* Video Settings */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="videoStyle"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Phong cách video *</FormLabel>
                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Chọn phong cách" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {videoStyles.map((style) => (
                              <SelectItem key={style.value} value={style.value}>
                                {style.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="duration"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Thời lượng *</FormLabel>
                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Chọn thời lượng" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {durations.map((duration) => (
                              <SelectItem key={duration.value} value={duration.value}>
                                {duration.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <FormField
                  control={form.control}
                  name="description"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Mô tả thêm (tùy chọn)</FormLabel>
                      <FormControl>
                        <Textarea 
                          placeholder="Mô tả chi tiết về hiệu ứng bạn muốn, chuyển động, âm thanh..." 
                          className="resize-none"
                          rows={3}
                          {...field} 
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <Button 
                  type="submit" 
                  className="w-full" 
                  disabled={mutation.isPending}
                >
                  {mutation.isPending ? (
                    "Đang gửi..."
                  ) : (
                    <>
                      <Send className="mr-2 h-4 w-4" />
                      Gửi yêu cầu tạo video
                    </>
                  )}
                </Button>
              </form>
            </Form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}