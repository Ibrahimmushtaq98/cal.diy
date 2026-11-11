import { EventTypeSelectComponent } from "@calcom/features/troubleshooter/components/EventTypeSelectComponent";
import { useEventTypesList } from "../../hooks/useEventTypesList";

import type { JSX } from "react";

export function EventTypeSelect(): JSX.Element {
  const { data: eventTypes, isPending } = useEventTypesList({});

  return (
    <EventTypeSelectComponent
      eventTypes={eventTypes ?? []}
      isPending={isPending}
    />
  );
}
