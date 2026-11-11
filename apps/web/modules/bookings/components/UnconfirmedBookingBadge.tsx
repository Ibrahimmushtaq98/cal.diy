"use client";

import { useRouter } from "next/navigation";

import { useLocale } from "@calcom/lib/hooks/useLocale";
import { trpc } from "@calcom/trpc/react";
import { Badge } from "@calcom/ui/components/badge";

export default function UnconfirmedBookingBadge() {
  const { t } = useLocale();
  const router = useRouter();
  const { data: unconfirmedBookingCount } = trpc.viewer.me.bookingUnconfirmedCount.useQuery();
  if (!unconfirmedBookingCount) return null;

  // The badge sits inside the sidebar's "Bookings" link, and a link can't contain another link.
  // So it navigates on click instead, and stops the parent link from handling the same click.
  const openUnconfirmed = (event: React.SyntheticEvent) => {
    event.preventDefault();
    event.stopPropagation();
    router.push("/bookings/unconfirmed");
  };

  return (
    <span
      role="link"
      tabIndex={0}
      onClick={openUnconfirmed}
      onKeyDown={(event) => {
        if (event.key === "Enter" || event.key === " ") openUnconfirmed(event);
      }}>
      <Badge
        rounded
        title={t("unconfirmed_bookings_tooltip")}
        variant="orange"
        className="cursor-pointer hover:bg-orange-800 hover:text-orange-100">
        {unconfirmedBookingCount}
      </Badge>
    </span>
  );
}
