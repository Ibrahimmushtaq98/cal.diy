"use client";

import dayjs from "@calcom/dayjs";
import cn from "@calcom/ui/classNames";
import { ChevronLeftIcon, ChevronRightIcon } from "@coss/ui/icons";
import type * as React from "react";
import type { Matcher } from "react-day-picker";
import { DayPicker } from "react-day-picker";
import { buttonClasses } from "../../button/Button";

// react-day-picker 9+ dropped `fromDate`/`toDate`. We keep them on our wrapper and turn them into
// navigation limits (startMonth/endMonth) plus disabled-day matchers, which is what they used to do.
export type CalendarProps = React.ComponentProps<typeof DayPicker> & {
  fromDate?: Date;
  toDate?: Date | null;
};

function toMatchers(disabled: Matcher | Matcher[] | undefined): Matcher[] {
  if (disabled === undefined) return [];
  return Array.isArray(disabled) ? disabled : [disabled];
}

function Calendar({
  className,
  classNames,
  fromDate,
  toDate,
  disabled,
  showOutsideDays = true,
  ...props
}: CalendarProps) {
  const disabledMatchers = [
    ...toMatchers(disabled),
    ...(fromDate ? [{ before: fromDate }] : []),
    ...(toDate ? [{ after: toDate }] : []),
  ];

  // In v9+ the selection modifiers (selected, range_*, disabled…) land on the grid cell, while the
  // clickable element is the inner button, so those classes style the button through the cell.
  return (
    <DayPicker
      startMonth={fromDate}
      endMonth={toDate || undefined}
      disabled={disabledMatchers.length > 0 ? disabledMatchers : undefined}
      showOutsideDays={showOutsideDays}
      className={cn("p-3", className)}
      classNames={{
        months: "relative flex flex-col sm:flex-row stack-y-4 sm:space-x-4 sm:stack-y-0",
        month: "stack-y-4",
        month_caption: "flex h-8 pt-1 items-center",
        caption_label: "text-sm font-medium",
        nav: "absolute right-0 top-0 z-10 flex items-center",
        button_previous: cn(buttonClasses({ color: "minimal", variant: "icon" })),
        button_next: cn(buttonClasses({ color: "minimal", variant: "icon" })),
        month_grid: "w-full border-collapse stack-y-1",
        weekdays: "flex w-full items-center justify-between",
        weekday: "w-8 md:w-11 h-8 text-sm font-medium text-default text-center",
        week: "flex w-full mt-0.5 gap-0.5",
        day: "w-8 h-8 md:h-11 md:w-11 text-center text-sm p-0 relative focus-within:relative focus-within:z-20",
        day_button: cn(
          buttonClasses({ color: "minimal" }),
          "w-8 h-8 md:h-11 md:w-11 p-0 text-sm font-medium aria-selected:opacity-100 inline-flex items-center justify-center"
        ),
        range_end: "[&>button]:hover:bg-inverted! [&>button]:text-inverted!",
        range_start: "[&>button]:hover:bg-inverted! [&>button]:text-inverted!",
        selected: "[&>button]:bg-inverted [&>button]:text-inverted",
        today: "",
        outside: "",
        disabled: "[&>button]:text-muted [&>button]:opacity-50",
        range_middle: "[&>button]:bg-emphasis! [&>button]:text-emphasis!",
        hidden: "invisible",
        ...classNames,
      }}
      components={{
        MonthCaption: ({ calendarMonth, displayIndex: _displayIndex, ...captionProps }) => (
          <div {...captionProps}>
            <div className="px-2">
              <span className="text-emphasis font-semibold leading-none">
                {dayjs(calendarMonth.date).format("MMMM")}{" "}
              </span>
              <span className="text-subtle font-medium leading-none">
                {dayjs(calendarMonth.date).format("YYYY")}
              </span>
            </div>
          </div>
        ),
        Chevron: ({ orientation }) =>
          orientation === "left" ? (
            <ChevronLeftIcon className="h-4 w-4 stroke-2" />
          ) : (
            <ChevronRightIcon className="h-4 w-4 stroke-2" />
          ),
      }}
      {...props}
    />
  );
}
Calendar.displayName = "Calendar";

export { Calendar };
