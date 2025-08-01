import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Settings, Key, RefreshCw, CheckCircle, AlertCircle } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

interface ApiKeyConfig {
  primary: string;
  backup: string;
  status: 'active' | 'inactive';
  lastUpdated: string;
}

export default function ApiConfig() {
  const [config, setConfig] = useState<ApiKeyConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [formData, setFormData] = useState<{ primary: string; backup: string; status: 'active' | 'inactive' }>({ primary: '', backup: '', status: 'active' });
  const { toast } = useToast();

  useEffect(() => {
    fetchApiKeys();
  }, []);

  const fetchApiKeys = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/config/clipdrop-keys');
      if (response.ok) {
        const data = await response.json();
        setConfig(data);
        setFormData({
          primary: data.primary,
          backup: data.backup,
          status: data.status
        });
      } else {
        throw new Error('Failed to fetch API keys');
      }
    } catch (error) {
      console.error('Error fetching API keys:', error);
      toast({
        title: "Error",
        description: "Failed to load API keys configuration",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const updateApiKeys = async () => {
    try {
      setSaving(true);
      const response = await fetch('/api/config/clipdrop-keys', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (response.ok) {
        const result = await response.json();
        setConfig(result.config);
        setEditMode(false);
        toast({
          title: "Success",
          description: "API keys updated successfully",
        });
      } else {
        throw new Error('Failed to update API keys');
      }
    } catch (error) {
      console.error('Error updating API keys:', error);
      toast({
        title: "Error",
        description: "Failed to update API keys",
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  const maskApiKey = (key: string) => {
    if (key.length <= 8) return key;
    return key.substring(0, 4) + '...' + key.substring(key.length - 4);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center">
        <div className="flex items-center space-x-2">
          <RefreshCw className="h-4 w-4 animate-spin" />
          <span>Loading configuration...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 p-4">
      <div className="max-w-4xl mx-auto space-y-6">
        <div className="text-center space-y-2">
          <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            API Configuration
          </h1>
          <p className="text-slate-600 dark:text-slate-400">
            Manage ClipDrop API keys for the AI Image Editor Flutter app
          </p>
        </div>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <Settings className="h-5 w-5" />
                <CardTitle>ClipDrop API Keys</CardTitle>
              </div>
              <div className="flex items-center space-x-2">
                <Badge variant={config?.status === 'active' ? 'default' : 'secondary'}>
                  {config?.status === 'active' ? (
                    <>
                      <CheckCircle className="h-3 w-3 mr-1" />
                      Active
                    </>
                  ) : (
                    <>
                      <AlertCircle className="h-3 w-3 mr-1" />
                      Inactive
                    </>
                  )}
                </Badge>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={fetchApiKeys}
                  disabled={loading}
                >
                  <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                  Refresh
                </Button>
              </div>
            </div>
            <CardDescription>
              These API keys are automatically fetched by the Flutter app.
              Updates take effect immediately without requiring app rebuild.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <Alert>
              <Key className="h-4 w-4" />
              <AlertDescription>
                Last updated: {config ? new Date(config.lastUpdated).toLocaleString() : 'Unknown'}
              </AlertDescription>
            </Alert>

            <div className="grid md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="primary">Primary API Key</Label>
                {editMode ? (
                  <Input
                    id="primary"
                    type="password"
                    value={formData.primary}
                    onChange={(e) => setFormData(prev => ({ ...prev, primary: e.target.value }))}
                    placeholder="Enter primary API key"
                  />
                ) : (
                  <div className="p-3 bg-slate-100 dark:bg-slate-800 rounded-md font-mono text-sm">
                    {config ? maskApiKey(config.primary) : 'Not set'}
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="backup">Backup API Key</Label>
                {editMode ? (
                  <Input
                    id="backup"
                    type="password"
                    value={formData.backup}
                    onChange={(e) => setFormData(prev => ({ ...prev, backup: e.target.value }))}
                    placeholder="Enter backup API key"
                  />
                ) : (
                  <div className="p-3 bg-slate-100 dark:bg-slate-800 rounded-md font-mono text-sm">
                    {config ? maskApiKey(config.backup) : 'Not set'}
                  </div>
                )}
              </div>
            </div>

            {editMode && (
              <div className="space-y-2">
                <Label htmlFor="status">Status</Label>
                <select
                  id="status"
                  value={formData.status}
                  onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value as 'active' | 'inactive' }))}
                  className="w-full p-2 border rounded-md bg-background"
                >
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>
            )}

            <div className="flex justify-end space-x-2">
              {editMode ? (
                <>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setEditMode(false);
                      setFormData({
                        primary: config?.primary || '',
                        backup: config?.backup || '',
                        status: (config?.status || 'active') as 'active' | 'inactive'
                      });
                    }}
                    disabled={saving}
                  >
                    Cancel
                  </Button>
                  <Button onClick={updateApiKeys} disabled={saving}>
                    {saving ? (
                      <>
                        <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                        Saving...
                      </>
                    ) : (
                      'Save Changes'
                    )}
                  </Button>
                </>
              ) : (
                <Button onClick={() => setEditMode(true)}>
                  <Settings className="h-4 w-4 mr-2" />
                  Edit Configuration
                </Button>
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">How it works</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3 text-sm text-slate-600 dark:text-slate-400">
              <div className="flex items-start space-x-2">
                <div className="w-2 h-2 rounded-full bg-blue-500 mt-2 flex-shrink-0" />
                <p>Flutter app automatically fetches API keys from this web server on startup</p>
              </div>
              <div className="flex items-start space-x-2">
                <div className="w-2 h-2 rounded-full bg-green-500 mt-2 flex-shrink-0" />
                <p>Keys are cached locally for offline use as fallback</p>
              </div>
              <div className="flex items-start space-x-2">
                <div className="w-2 h-2 rounded-full bg-purple-500 mt-2 flex-shrink-0" />
                <p>Changes take effect immediately without rebuilding the app</p>
              </div>
              <div className="flex items-start space-x-2">
                <div className="w-2 h-2 rounded-full bg-orange-500 mt-2 flex-shrink-0" />
                <p>Backup API key is used automatically if primary key fails</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}