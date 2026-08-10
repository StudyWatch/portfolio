import { Component, type ErrorInfo, type ReactNode } from "react";

interface ErrorBoundaryProps {
  children: ReactNode;
  /** Rendered in place of the crashed subtree. Defaults to nothing. */
  fallback?: ReactNode;
  /** Fires once, right after the crash is caught - e.g. to unblock a stuck loading state. */
  onError?: (error: Error, info: ErrorInfo) => void;
}

interface ErrorBoundaryState {
  hasError: boolean;
}

// 3D (WebGL/GLB) is an enhancement, not a hard dependency of the portfolio.
// Any subtree that can fail on a constrained device/browser (blocked WebGL
// context, a corrupt/missing asset, a GPU/memory exception) is wrapped in
// this boundary so a crash there degrades to "this piece is missing," not
// "the whole site unmounts to a black screen."
class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error("[ErrorBoundary] Caught a render-time error:", error, info);
    this.props.onError?.(error, info);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? null;
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
