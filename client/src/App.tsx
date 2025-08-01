import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import Home from "@/pages/home";
import Generation from "@/pages/generation";
import Upload from "@/pages/upload";
import Editor from "@/pages/editor";
import AppleCleanup from "@/pages/apple-cleanup";
// ApiConfig moved to separate server
import NotFound from "@/pages/not-found";

function Router() {
  return (
    <Switch>
      <Route path="/" component={Home} />
      <Route path="/generation" component={Generation} />
      <Route path="/upload" component={Upload} />
      <Route path="/editor" component={Editor} />
      <Route path="/apple-cleanup" component={AppleCleanup} />
      {/* API config moved to separate server */}
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Router />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
