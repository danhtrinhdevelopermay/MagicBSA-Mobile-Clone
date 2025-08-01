// API Keys Configuration
// Cấu hình API keys cho các dịch vụ bên ngoài

export interface ApiKeyConfig {
  clipdrop: {
    primary: string;
    backup: string;
    status: 'active' | 'inactive';
    lastUpdated: string;
  };
}

// API Keys - có thể thay đổi mà không cần rebuild app
export const API_KEYS: ApiKeyConfig = {
  clipdrop: {
    primary: '2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664',
    backup: '7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2',
    status: 'active',
    lastUpdated: new Date().toISOString()
  }
};

// Helper function để update API keys
export function updateApiKeys(newKeys: Partial<ApiKeyConfig>): void {
  if (newKeys.clipdrop) {
    API_KEYS.clipdrop = {
      ...API_KEYS.clipdrop,
      ...newKeys.clipdrop,
      lastUpdated: new Date().toISOString()
    };
  }
}

// Helper function để get current API key
export function getCurrentClipDropApiKey(): string {
  return API_KEYS.clipdrop.status === 'active' 
    ? API_KEYS.clipdrop.primary 
    : API_KEYS.clipdrop.backup;
}