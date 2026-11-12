import { render, fireEvent } from "@testing-library/react";
import { format } from "date-fns";
import { vi } from "vitest";

import DatePicker from "./DatePicker";

const onChangeMock = vi.fn();

describe("Tests for DatePicker Component", () => {
  const testDate = new Date("2024-02-20");

  test("Should render correctly with default date", () => {
    const testDate = new Date("2024-02-20");
    const { getByTestId } = render(<DatePicker date={testDate} />);

    const dateButton = getByTestId("pick-date");
    expect(dateButton).toHaveTextContent(format(testDate, "LLL dd, y"));
  });

  test("Should show placeholder when no date is provided", () => {
    const { getByTestId } = render(<DatePicker date={null as unknown as Date} />);

    const dateButton = getByTestId("pick-date");
    expect(dateButton).toHaveTextContent("Pick a date");
  });

  test("Should handle date selection correctly", async () => {
    const testDate = new Date("2024-02-20");
    const { getByTestId, getAllByRole } = render(<DatePicker date={testDate} onDatesChange={onChangeMock} />);

    const dateButton = getByTestId("pick-date");
    fireEvent.click(dateButton);
    // react-day-picker 9+ puts the gridcell role on the cell and the focusable button inside it.
    const gridCells = getAllByRole("gridcell");
    const selectedDate = gridCells.find((cell) => cell.querySelector("button")?.getAttribute("tabindex") === "0");

    expect(selectedDate).toBeTruthy();
    expect(selectedDate).not.toHaveAttribute("data-disabled");
  });
  test("Should respect minDate prop", async () => {
    const testDate = new Date("2024-02-20");
    const minDate = new Date("2024-02-19");
    const { getByTestId, getAllByRole } = render(
      <DatePicker date={testDate} minDate={minDate} onDatesChange={onChangeMock} />
    );

    const dateButton = getByTestId("pick-date");
    fireEvent.click(dateButton);

    const disabledDates = getAllByRole("gridcell").filter(
      // Outside days before the first navigable month are hidden (no button), so skip them.
      (cell) => cell.hasAttribute("data-disabled") && !cell.hasAttribute("data-hidden")
    );
    expect(disabledDates.length).toBeGreaterThan(0);
    expect(disabledDates[0].querySelector("button")).toHaveAttribute("disabled");
  });

  test("Should respect disabled prop", () => {
    const { getByTestId } = render(<DatePicker date={testDate} disabled={true} />);

    const dateButton = getByTestId("pick-date");
    expect(dateButton.classList.toString()).toContain("disabled:cursor-not-allowed");
    expect(dateButton.classList.toString()).toContain("disabled:opacity-30");
  });
});
