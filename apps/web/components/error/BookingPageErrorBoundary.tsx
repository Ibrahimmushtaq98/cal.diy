import { captureReactException } from "@sentry/nextjs";
import React from "react";
import { ErrorBoundary } from "react-error-boundary";

import { ErrorPage } from "./error-page";

export default function BookingPageErrorBoundary({ children }: { children: React.ReactNode }) {
  return (
    <ErrorBoundary
      fallbackRender={({ error, resetErrorBoundary }) => (
        // react-error-boundary 6 types the caught value as unknown.
        <ErrorPage
          reset={resetErrorBoundary}
          error={error instanceof Error ? error : new Error(String(error))}
          message={`${error}`}
          displayDebug={true}
        />
      )}
      onError={(error, info) => {
        console.error(error);
        captureReactException(error, info);
      }}>
      {children}
    </ErrorBoundary>
  );
}
