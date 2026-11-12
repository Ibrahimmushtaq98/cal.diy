import { renderHook } from "@testing-library/react";
import { useRouter } from "next/compat/router";
import { useParams } from "next/navigation";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { useParamsWithFallback } from "./useParamsWithFallback";

// vi.mock is hoisted to the top of the file, so mock once here and set return values per test.
vi.mock("next/navigation", () => ({
  useParams: vi.fn(),
}));

vi.mock("next/compat/router", () => ({
  useRouter: vi.fn(),
}));

describe("useParamsWithFallback hook", () => {
  beforeEach(() => {
    vi.mocked(useParams).mockReset();
    vi.mocked(useRouter).mockReset();
  });

  it("should return router.query when param is null", () => {
    vi.mocked(useParams).mockReturnValue(null);
    vi.mocked(useRouter).mockReturnValue({ query: { id: "1" } } as unknown as ReturnType<typeof useRouter>);

    const { result } = renderHook(() => useParamsWithFallback());

    expect(result.current).toEqual({ id: "1" });
  });

  it("should return router.query when param is undefined", () => {
    vi.mocked(useParams).mockReturnValue(undefined as unknown as ReturnType<typeof useParams>);
    vi.mocked(useRouter).mockReturnValue({ query: { id: "1" } } as unknown as ReturnType<typeof useRouter>);

    const { result } = renderHook(() => useParamsWithFallback());

    expect(result.current).toEqual({ id: "1" });
  });

  it("should return useParams() if it exists", () => {
    vi.mocked(useParams).mockReturnValue({ id: "1" });
    vi.mocked(useRouter).mockReturnValue({ query: { id: "2" } } as unknown as ReturnType<typeof useRouter>);

    const { result } = renderHook(() => useParamsWithFallback());

    expect(result.current).toEqual({ id: "1" });
  });

  it("should return an empty object when neither is available", () => {
    vi.mocked(useParams).mockReturnValue(null);
    vi.mocked(useRouter).mockReturnValue(null);

    const { result } = renderHook(() => useParamsWithFallback());

    expect(result.current).toEqual({});
  });
});
