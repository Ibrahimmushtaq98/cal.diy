BEGIN TRY

BEGIN TRAN;

-- CreateSchema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbo') EXEC sp_executesql N'CREATE SCHEMA [dbo];';

-- CreateTable
CREATE TABLE [dbo].[Host] (
    [userId] INT NOT NULL,
    [eventTypeId] INT NOT NULL,
    [isFixed] BIT NOT NULL CONSTRAINT [Host_isFixed_df] DEFAULT 0,
    [priority] INT,
    [weight] INT,
    [weightAdjustment] INT,
    [scheduleId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Host_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [groupId] NVARCHAR(1000),
    [memberId] INT,
    CONSTRAINT [Host_pkey] PRIMARY KEY CLUSTERED ([userId],[eventTypeId])
);

-- CreateTable
CREATE TABLE [dbo].[HostGroup] (
    [id] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(1000) NOT NULL,
    [eventTypeId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [HostGroup_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [HostGroup_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[HostLocation] (
    [id] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [eventTypeId] INT NOT NULL,
    [type] NVARCHAR(max) NOT NULL,
    [credentialId] INT,
    [link] NVARCHAR(max),
    [address] NVARCHAR(max),
    [phoneNumber] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [HostLocation_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [HostLocation_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [HostLocation_userId_eventTypeId_key] UNIQUE NONCLUSTERED ([userId],[eventTypeId])
);

-- CreateTable
CREATE TABLE [dbo].[CalVideoSettings] (
    [eventTypeId] INT NOT NULL,
    [disableRecordingForOrganizer] BIT NOT NULL CONSTRAINT [CalVideoSettings_disableRecordingForOrganizer_df] DEFAULT 0,
    [disableRecordingForGuests] BIT NOT NULL CONSTRAINT [CalVideoSettings_disableRecordingForGuests_df] DEFAULT 0,
    [enableAutomaticTranscription] BIT NOT NULL CONSTRAINT [CalVideoSettings_enableAutomaticTranscription_df] DEFAULT 0,
    [enableAutomaticRecordingForOrganizer] BIT NOT NULL CONSTRAINT [CalVideoSettings_enableAutomaticRecordingForOrganizer_df] DEFAULT 0,
    [redirectUrlOnExit] NVARCHAR(max),
    [disableTranscriptionForGuests] BIT NOT NULL CONSTRAINT [CalVideoSettings_disableTranscriptionForGuests_df] DEFAULT 0,
    [disableTranscriptionForOrganizer] BIT NOT NULL CONSTRAINT [CalVideoSettings_disableTranscriptionForOrganizer_df] DEFAULT 0,
    [requireEmailForGuests] BIT NOT NULL CONSTRAINT [CalVideoSettings_requireEmailForGuests_df] DEFAULT 0,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [CalVideoSettings_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [CalVideoSettings_pkey] PRIMARY KEY CLUSTERED ([eventTypeId])
);

-- CreateTable
CREATE TABLE [dbo].[VideoCallGuest] (
    [id] NVARCHAR(1000) NOT NULL,
    [bookingUid] NVARCHAR(1000) NOT NULL,
    [email] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [joinedAt] DATETIME2,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [VideoCallGuest_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [VideoCallGuest_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [VideoCallGuest_bookingUid_email_key] UNIQUE NONCLUSTERED ([bookingUid],[email])
);

-- CreateTable
CREATE TABLE [dbo].[EventType] (
    [id] INT NOT NULL IDENTITY(1,1),
    [title] NVARCHAR(max) NOT NULL,
    [slug] NVARCHAR(1000) NOT NULL,
    [description] NVARCHAR(max),
    [interfaceLanguage] NVARCHAR(max),
    [position] INT NOT NULL CONSTRAINT [EventType_position_df] DEFAULT 0,
    [locations] NVARCHAR(max),
    [length] INT NOT NULL,
    [offsetStart] INT NOT NULL CONSTRAINT [EventType_offsetStart_df] DEFAULT 0,
    [hidden] BIT NOT NULL CONSTRAINT [EventType_hidden_df] DEFAULT 0,
    [userId] INT,
    [profileId] INT,
    [teamId] INT,
    [useEventLevelSelectedCalendars] BIT NOT NULL CONSTRAINT [EventType_useEventLevelSelectedCalendars_df] DEFAULT 0,
    [eventName] NVARCHAR(max),
    [parentId] INT,
    [bookingFields] NVARCHAR(max),
    [timeZone] NVARCHAR(max),
    [periodType] NVARCHAR(100) NOT NULL CONSTRAINT [EventType_periodType_df] DEFAULT 'UNLIMITED',
    [periodStartDate] DATETIME2,
    [periodEndDate] DATETIME2,
    [periodDays] INT,
    [periodCountCalendarDays] BIT,
    [lockTimeZoneToggleOnBookingPage] BIT NOT NULL CONSTRAINT [EventType_lockTimeZoneToggleOnBookingPage_df] DEFAULT 0,
    [lockedTimeZone] NVARCHAR(max),
    [requiresConfirmation] BIT NOT NULL CONSTRAINT [EventType_requiresConfirmation_df] DEFAULT 0,
    [requiresConfirmationWillBlockSlot] BIT NOT NULL CONSTRAINT [EventType_requiresConfirmationWillBlockSlot_df] DEFAULT 0,
    [requiresConfirmationForFreeEmail] BIT NOT NULL CONSTRAINT [EventType_requiresConfirmationForFreeEmail_df] DEFAULT 0,
    [requiresBookerEmailVerification] BIT NOT NULL CONSTRAINT [EventType_requiresBookerEmailVerification_df] DEFAULT 0,
    [canSendCalVideoTranscriptionEmails] BIT NOT NULL CONSTRAINT [EventType_canSendCalVideoTranscriptionEmails_df] DEFAULT 1,
    [autoTranslateDescriptionEnabled] BIT NOT NULL CONSTRAINT [EventType_autoTranslateDescriptionEnabled_df] DEFAULT 0,
    [autoTranslateInstantMeetingTitleEnabled] BIT NOT NULL CONSTRAINT [EventType_autoTranslateInstantMeetingTitleEnabled_df] DEFAULT 1,
    [recurringEvent] NVARCHAR(max),
    [disableGuests] BIT NOT NULL CONSTRAINT [EventType_disableGuests_df] DEFAULT 0,
    [hideCalendarNotes] BIT NOT NULL CONSTRAINT [EventType_hideCalendarNotes_df] DEFAULT 0,
    [hideCalendarEventDetails] BIT NOT NULL CONSTRAINT [EventType_hideCalendarEventDetails_df] DEFAULT 0,
    [minimumBookingNotice] INT NOT NULL CONSTRAINT [EventType_minimumBookingNotice_df] DEFAULT 120,
    [beforeEventBuffer] INT NOT NULL CONSTRAINT [EventType_beforeEventBuffer_df] DEFAULT 0,
    [afterEventBuffer] INT NOT NULL CONSTRAINT [EventType_afterEventBuffer_df] DEFAULT 0,
    [seatsPerTimeSlot] INT,
    [onlyShowFirstAvailableSlot] BIT NOT NULL CONSTRAINT [EventType_onlyShowFirstAvailableSlot_df] DEFAULT 0,
    [showOptimizedSlots] BIT CONSTRAINT [EventType_showOptimizedSlots_df] DEFAULT 0,
    [disableCancelling] BIT CONSTRAINT [EventType_disableCancelling_df] DEFAULT 0,
    [disableRescheduling] BIT CONSTRAINT [EventType_disableRescheduling_df] DEFAULT 0,
    [minimumRescheduleNotice] INT,
    [seatsShowAttendees] BIT CONSTRAINT [EventType_seatsShowAttendees_df] DEFAULT 0,
    [seatsShowAvailabilityCount] BIT CONSTRAINT [EventType_seatsShowAvailabilityCount_df] DEFAULT 1,
    [schedulingType] NVARCHAR(100),
    [scheduleId] INT,
    [allowReschedulingCancelledBookings] BIT CONSTRAINT [EventType_allowReschedulingCancelledBookings_df] DEFAULT 0,
    [price] INT NOT NULL CONSTRAINT [EventType_price_df] DEFAULT 0,
    [currency] NVARCHAR(max) NOT NULL CONSTRAINT [EventType_currency_df] DEFAULT 'usd',
    [slotInterval] INT,
    [metadata] NVARCHAR(max),
    [successRedirectUrl] NVARCHAR(max),
    [forwardParamsSuccessRedirect] BIT CONSTRAINT [EventType_forwardParamsSuccessRedirect_df] DEFAULT 1,
    [bookingLimits] NVARCHAR(max),
    [durationLimits] NVARCHAR(max),
    [isInstantEvent] BIT NOT NULL CONSTRAINT [EventType_isInstantEvent_df] DEFAULT 0,
    [instantMeetingExpiryTimeOffsetInSeconds] INT NOT NULL CONSTRAINT [EventType_instantMeetingExpiryTimeOffsetInSeconds_df] DEFAULT 90,
    [instantMeetingScheduleId] INT,
    [instantMeetingParameters] NVARCHAR(max) NOT NULL CONSTRAINT [EventType_instantMeetingParameters_df] DEFAULT '[]',
    [assignAllTeamMembers] BIT NOT NULL CONSTRAINT [EventType_assignAllTeamMembers_df] DEFAULT 0,
    [assignRRMembersUsingSegment] BIT NOT NULL CONSTRAINT [EventType_assignRRMembersUsingSegment_df] DEFAULT 0,
    [rrSegmentQueryValue] NVARCHAR(max),
    [useEventTypeDestinationCalendarEmail] BIT NOT NULL CONSTRAINT [EventType_useEventTypeDestinationCalendarEmail_df] DEFAULT 0,
    [isRRWeightsEnabled] BIT NOT NULL CONSTRAINT [EventType_isRRWeightsEnabled_df] DEFAULT 0,
    [maxLeadThreshold] INT,
    [includeNoShowInRRCalculation] BIT NOT NULL CONSTRAINT [EventType_includeNoShowInRRCalculation_df] DEFAULT 0,
    [allowReschedulingPastBookings] BIT NOT NULL CONSTRAINT [EventType_allowReschedulingPastBookings_df] DEFAULT 0,
    [hideOrganizerEmail] BIT NOT NULL CONSTRAINT [EventType_hideOrganizerEmail_df] DEFAULT 0,
    [maxActiveBookingsPerBooker] INT,
    [maxActiveBookingPerBookerOfferReschedule] BIT NOT NULL CONSTRAINT [EventType_maxActiveBookingPerBookerOfferReschedule_df] DEFAULT 0,
    [customReplyToEmail] NVARCHAR(max),
    [eventTypeColor] NVARCHAR(max),
    [rescheduleWithSameRoundRobinHost] BIT NOT NULL CONSTRAINT [EventType_rescheduleWithSameRoundRobinHost_df] DEFAULT 0,
    [secondaryEmailId] INT,
    [useBookerTimezone] BIT NOT NULL CONSTRAINT [EventType_useBookerTimezone_df] DEFAULT 0,
    [restrictionScheduleId] INT,
    [bookingRequiresAuthentication] BIT NOT NULL CONSTRAINT [EventType_bookingRequiresAuthentication_df] DEFAULT 0,
    [rrHostSubsetEnabled] BIT NOT NULL CONSTRAINT [EventType_rrHostSubsetEnabled_df] DEFAULT 0,
    [requiresCancellationReason] NVARCHAR(100) CONSTRAINT [EventType_requiresCancellationReason_df] DEFAULT 'MANDATORY_HOST_ONLY',
    [enablePerHostLocations] BIT NOT NULL CONSTRAINT [EventType_enablePerHostLocations_df] DEFAULT 0,
    [createdAt] DATETIME2 CONSTRAINT [EventType_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2,
    CONSTRAINT [EventType_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [EventType_userId_slug_key] ON [dbo].[EventType]([userId],[slug]) WHERE [userId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [EventType_teamId_slug_key] ON [dbo].[EventType]([teamId],[slug]) WHERE [teamId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [EventType_userId_parentId_key] ON [dbo].[EventType]([userId],[parentId]) WHERE [userId] IS NOT NULL AND [parentId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[Credential] (
    [id] INT NOT NULL IDENTITY(1,1),
    [type] NVARCHAR(max) NOT NULL,
    [key] NVARCHAR(max) NOT NULL,
    [encryptedKey] NVARCHAR(max),
    [userId] INT,
    [teamId] INT,
    [appId] NVARCHAR(1000),
    [subscriptionId] NVARCHAR(1000),
    [paymentStatus] NVARCHAR(max),
    [billingCycleStart] INT,
    [invalid] BIT CONSTRAINT [Credential_invalid_df] DEFAULT 0,
    [delegationCredentialId] NVARCHAR(1000),
    CONSTRAINT [Credential_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[DestinationCalendar] (
    [id] INT NOT NULL IDENTITY(1,1),
    [integration] NVARCHAR(max) NOT NULL,
    [externalId] NVARCHAR(max) NOT NULL,
    [primaryEmail] NVARCHAR(max),
    [userId] INT,
    [eventTypeId] INT,
    [credentialId] INT,
    [createdAt] DATETIME2 CONSTRAINT [DestinationCalendar_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2,
    [delegationCredentialId] NVARCHAR(1000),
    [customCalendarReminder] INT,
    CONSTRAINT [DestinationCalendar_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [DestinationCalendar_userId_key] ON [dbo].[DestinationCalendar]([userId]) WHERE [userId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [DestinationCalendar_eventTypeId_key] ON [dbo].[DestinationCalendar]([eventTypeId]) WHERE [eventTypeId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[UserPassword] (
    [hash] NVARCHAR(max) NOT NULL,
    [userId] INT NOT NULL,
    CONSTRAINT [UserPassword_userId_key] UNIQUE NONCLUSTERED ([userId])
);

-- CreateTable
CREATE TABLE [dbo].[TravelSchedule] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [timeZone] NVARCHAR(max) NOT NULL,
    [startDate] DATETIME2 NOT NULL,
    [endDate] DATETIME2,
    [prevTimeZone] NVARCHAR(max),
    CONSTRAINT [TravelSchedule_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[users] (
    [id] INT NOT NULL IDENTITY(1,1),
    [uuid] UNIQUEIDENTIFIER NOT NULL,
    [username] NVARCHAR(1000),
    [name] NVARCHAR(max),
    [email] NVARCHAR(1000) NOT NULL,
    [emailVerified] DATETIME2,
    [bio] NVARCHAR(max),
    [avatarUrl] NVARCHAR(max),
    [timeZone] NVARCHAR(max) NOT NULL CONSTRAINT [users_timeZone_df] DEFAULT 'Europe/London',
    [weekStart] NVARCHAR(max) NOT NULL CONSTRAINT [users_weekStart_df] DEFAULT 'Sunday',
    [bufferTime] INT NOT NULL CONSTRAINT [users_bufferTime_df] DEFAULT 0,
    [hideBranding] BIT NOT NULL CONSTRAINT [users_hideBranding_df] DEFAULT 0,
    [theme] NVARCHAR(max),
    [appTheme] NVARCHAR(max),
    [created] DATETIME2 NOT NULL CONSTRAINT [users_created_df] DEFAULT CURRENT_TIMESTAMP,
    [trialEndsAt] DATETIME2,
    [lastActiveAt] DATETIME2,
    [defaultScheduleId] INT,
    [completedOnboarding] BIT NOT NULL CONSTRAINT [users_completedOnboarding_df] DEFAULT 0,
    [locale] NVARCHAR(max),
    [timeFormat] INT CONSTRAINT [users_timeFormat_df] DEFAULT 12,
    [twoFactorSecret] NVARCHAR(max),
    [twoFactorEnabled] BIT NOT NULL CONSTRAINT [users_twoFactorEnabled_df] DEFAULT 0,
    [backupCodes] NVARCHAR(max),
    [identityProvider] NVARCHAR(100) NOT NULL CONSTRAINT [users_identityProvider_df] DEFAULT 'CAL',
    [identityProviderId] NVARCHAR(1000),
    [invitedTo] INT,
    [brandColor] NVARCHAR(max),
    [darkBrandColor] NVARCHAR(max),
    [allowDynamicBooking] BIT CONSTRAINT [users_allowDynamicBooking_df] DEFAULT 1,
    [allowSEOIndexing] BIT CONSTRAINT [users_allowSEOIndexing_df] DEFAULT 1,
    [receiveMonthlyDigestEmail] BIT CONSTRAINT [users_receiveMonthlyDigestEmail_df] DEFAULT 1,
    [requiresBookerEmailVerification] BIT CONSTRAINT [users_requiresBookerEmailVerification_df] DEFAULT 0,
    [metadata] NVARCHAR(max),
    [verified] BIT CONSTRAINT [users_verified_df] DEFAULT 0,
    [role] NVARCHAR(100) NOT NULL CONSTRAINT [users_role_df] DEFAULT 'USER',
    [organizationId] INT,
    [locked] BIT NOT NULL CONSTRAINT [users_locked_df] DEFAULT 0,
    [movedToProfileId] INT,
    [isPlatformManaged] BIT NOT NULL CONSTRAINT [users_isPlatformManaged_df] DEFAULT 0,
    [smsLockState] NVARCHAR(100) NOT NULL CONSTRAINT [users_smsLockState_df] DEFAULT 'UNLOCKED',
    [smsLockReviewedByAdmin] BIT NOT NULL CONSTRAINT [users_smsLockReviewedByAdmin_df] DEFAULT 0,
    [referralLinkId] NVARCHAR(max),
    [creationSource] NVARCHAR(100),
    [autoOptInFeatures] BIT NOT NULL CONSTRAINT [users_autoOptInFeatures_df] DEFAULT 0,
    CONSTRAINT [users_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [users_uuid_key] UNIQUE NONCLUSTERED ([uuid]),
    CONSTRAINT [users_email_key] UNIQUE NONCLUSTERED ([email])
);

CREATE UNIQUE NONCLUSTERED INDEX [users_email_username_key] ON [dbo].[users]([email],[username]) WHERE [username] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [users_username_organizationId_key] ON [dbo].[users]([username],[organizationId]) WHERE [username] IS NOT NULL AND [organizationId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [users_movedToProfileId_key] ON [dbo].[users]([movedToProfileId]) WHERE [movedToProfileId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[NotificationsSubscriptions] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [subscription] NVARCHAR(1000) NOT NULL,
    CONSTRAINT [NotificationsSubscriptions_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Profile] (
    [id] INT NOT NULL IDENTITY(1,1),
    [uid] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [organizationId] INT NOT NULL,
    [username] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Profile_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [Profile_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Profile_userId_organizationId_key] UNIQUE NONCLUSTERED ([userId],[organizationId]),
    CONSTRAINT [Profile_username_organizationId_key] UNIQUE NONCLUSTERED ([username],[organizationId])
);

-- CreateTable
CREATE TABLE [dbo].[Team] (
    [id] INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(max) NOT NULL,
    [slug] NVARCHAR(1000),
    [logoUrl] NVARCHAR(max),
    [calVideoLogo] NVARCHAR(max),
    [appLogo] NVARCHAR(max),
    [appIconLogo] NVARCHAR(max),
    [bio] NVARCHAR(max),
    [hideBranding] BIT NOT NULL CONSTRAINT [Team_hideBranding_df] DEFAULT 0,
    [hideTeamProfileLink] BIT NOT NULL CONSTRAINT [Team_hideTeamProfileLink_df] DEFAULT 0,
    [isPrivate] BIT NOT NULL CONSTRAINT [Team_isPrivate_df] DEFAULT 0,
    [hideBookATeamMember] BIT NOT NULL CONSTRAINT [Team_hideBookATeamMember_df] DEFAULT 0,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Team_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [metadata] NVARCHAR(max),
    [theme] NVARCHAR(max),
    [rrResetInterval] NVARCHAR(100) CONSTRAINT [Team_rrResetInterval_df] DEFAULT 'MONTH',
    [rrTimestampBasis] NVARCHAR(100) NOT NULL CONSTRAINT [Team_rrTimestampBasis_df] DEFAULT 'CREATED_AT',
    [brandColor] NVARCHAR(max),
    [darkBrandColor] NVARCHAR(max),
    [bannerUrl] NVARCHAR(max),
    [parentId] INT,
    [timeFormat] INT,
    [timeZone] NVARCHAR(max) NOT NULL CONSTRAINT [Team_timeZone_df] DEFAULT 'Europe/London',
    [weekStart] NVARCHAR(max) NOT NULL CONSTRAINT [Team_weekStart_df] DEFAULT 'Sunday',
    [isOrganization] BIT NOT NULL CONSTRAINT [Team_isOrganization_df] DEFAULT 0,
    [pendingPayment] BIT NOT NULL CONSTRAINT [Team_pendingPayment_df] DEFAULT 0,
    [isPlatform] BIT NOT NULL CONSTRAINT [Team_isPlatform_df] DEFAULT 0,
    [createdByOAuthClientId] NVARCHAR(1000),
    [smsLockState] NVARCHAR(100) NOT NULL CONSTRAINT [Team_smsLockState_df] DEFAULT 'UNLOCKED',
    [smsLockReviewedByAdmin] BIT NOT NULL CONSTRAINT [Team_smsLockReviewedByAdmin_df] DEFAULT 0,
    [bookingLimits] NVARCHAR(max),
    [includeManagedEventsInLimits] BIT NOT NULL CONSTRAINT [Team_includeManagedEventsInLimits_df] DEFAULT 0,
    [autoOptInFeatures] BIT NOT NULL CONSTRAINT [Team_autoOptInFeatures_df] DEFAULT 0,
    CONSTRAINT [Team_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [Team_slug_parentId_key] ON [dbo].[Team]([slug],[parentId]) WHERE [slug] IS NOT NULL AND [parentId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[CreditBalance] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT,
    [userId] INT,
    [additionalCredits] INT NOT NULL CONSTRAINT [CreditBalance_additionalCredits_df] DEFAULT 0,
    [limitReachedAt] DATETIME2,
    [warningSentAt] DATETIME2,
    CONSTRAINT [CreditBalance_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [CreditBalance_teamId_key] ON [dbo].[CreditBalance]([teamId]) WHERE [teamId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [CreditBalance_userId_key] ON [dbo].[CreditBalance]([userId]) WHERE [userId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[CreditPurchaseLog] (
    [id] NVARCHAR(1000) NOT NULL,
    [creditBalanceId] NVARCHAR(1000) NOT NULL,
    [credits] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [CreditPurchaseLog_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [CreditPurchaseLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[CreditExpenseLog] (
    [id] NVARCHAR(1000) NOT NULL,
    [creditBalanceId] NVARCHAR(1000) NOT NULL,
    [bookingUid] NVARCHAR(1000),
    [credits] INT,
    [creditType] NVARCHAR(100) NOT NULL,
    [date] DATETIME2 NOT NULL,
    [smsSid] NVARCHAR(max),
    [smsSegments] INT,
    [phoneNumber] NVARCHAR(max),
    [email] NVARCHAR(max),
    [callDuration] INT,
    [creditFor] NVARCHAR(100),
    [externalRef] NVARCHAR(1000),
    CONSTRAINT [CreditExpenseLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [CreditExpenseLog_externalRef_key] ON [dbo].[CreditExpenseLog]([externalRef]) WHERE [externalRef] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[OrganizationSettings] (
    [id] INT NOT NULL IDENTITY(1,1),
    [organizationId] INT NOT NULL,
    [isOrganizationConfigured] BIT NOT NULL CONSTRAINT [OrganizationSettings_isOrganizationConfigured_df] DEFAULT 0,
    [isOrganizationVerified] BIT NOT NULL CONSTRAINT [OrganizationSettings_isOrganizationVerified_df] DEFAULT 0,
    [orgAutoAcceptEmail] NVARCHAR(max) NOT NULL,
    [lockEventTypeCreationForUsers] BIT NOT NULL CONSTRAINT [OrganizationSettings_lockEventTypeCreationForUsers_df] DEFAULT 0,
    [adminGetsNoSlotsNotification] BIT NOT NULL CONSTRAINT [OrganizationSettings_adminGetsNoSlotsNotification_df] DEFAULT 0,
    [isAdminReviewed] BIT NOT NULL CONSTRAINT [OrganizationSettings_isAdminReviewed_df] DEFAULT 0,
    [isAdminAPIEnabled] BIT NOT NULL CONSTRAINT [OrganizationSettings_isAdminAPIEnabled_df] DEFAULT 0,
    [allowSEOIndexing] BIT NOT NULL CONSTRAINT [OrganizationSettings_allowSEOIndexing_df] DEFAULT 0,
    [orgProfileRedirectsToVerifiedDomain] BIT NOT NULL CONSTRAINT [OrganizationSettings_orgProfileRedirectsToVerifiedDomain_df] DEFAULT 0,
    [disablePhoneOnlySMSNotifications] BIT NOT NULL CONSTRAINT [OrganizationSettings_disablePhoneOnlySMSNotifications_df] DEFAULT 0,
    [disableAutofillOnBookingPage] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAutofillOnBookingPage_df] DEFAULT 0,
    [orgAutoJoinOnSignup] BIT NOT NULL CONSTRAINT [OrganizationSettings_orgAutoJoinOnSignup_df] DEFAULT 1,
    [disableAttendeeConfirmationEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeConfirmationEmail_df] DEFAULT 0,
    [disableAttendeeCancellationEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeCancellationEmail_df] DEFAULT 0,
    [disableAttendeeRescheduledEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeRescheduledEmail_df] DEFAULT 0,
    [disableAttendeeRequestEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeRequestEmail_df] DEFAULT 0,
    [disableAttendeeReassignedEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeReassignedEmail_df] DEFAULT 0,
    [disableAttendeeAwaitingPaymentEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeAwaitingPaymentEmail_df] DEFAULT 0,
    [disableAttendeeRescheduleRequestEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeRescheduleRequestEmail_df] DEFAULT 0,
    [disableAttendeeLocationChangeEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeLocationChangeEmail_df] DEFAULT 0,
    [disableAttendeeNewEventEmail] BIT NOT NULL CONSTRAINT [OrganizationSettings_disableAttendeeNewEventEmail_df] DEFAULT 0,
    CONSTRAINT [OrganizationSettings_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [OrganizationSettings_organizationId_key] UNIQUE NONCLUSTERED ([organizationId])
);

-- CreateTable
CREATE TABLE [dbo].[Membership] (
    [id] INT NOT NULL IDENTITY(1,1),
    [teamId] INT NOT NULL,
    [userId] INT NOT NULL,
    [accepted] BIT NOT NULL CONSTRAINT [Membership_accepted_df] DEFAULT 0,
    [role] NVARCHAR(100) NOT NULL,
    [customRoleId] NVARCHAR(1000),
    [createdAt] DATETIME2 CONSTRAINT [Membership_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2,
    CONSTRAINT [Membership_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Membership_userId_teamId_key] UNIQUE NONCLUSTERED ([userId],[teamId])
);

-- CreateTable
CREATE TABLE [dbo].[VerificationToken] (
    [id] INT NOT NULL IDENTITY(1,1),
    [identifier] NVARCHAR(1000) NOT NULL,
    [token] NVARCHAR(1000) NOT NULL,
    [expires] DATETIME2 NOT NULL,
    [expiresInDays] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [VerificationToken_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [teamId] INT,
    [secondaryEmailId] INT,
    CONSTRAINT [VerificationToken_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [VerificationToken_token_key] UNIQUE NONCLUSTERED ([token]),
    CONSTRAINT [VerificationToken_identifier_token_key] UNIQUE NONCLUSTERED ([identifier],[token])
);

-- CreateTable
CREATE TABLE [dbo].[InstantMeetingToken] (
    [id] INT NOT NULL IDENTITY(1,1),
    [token] NVARCHAR(1000) NOT NULL,
    [expires] DATETIME2 NOT NULL,
    [teamId] INT NOT NULL,
    [bookingId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [InstantMeetingToken_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [InstantMeetingToken_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [InstantMeetingToken_token_key] UNIQUE NONCLUSTERED ([token])
);

CREATE UNIQUE NONCLUSTERED INDEX [InstantMeetingToken_bookingId_key] ON [dbo].[InstantMeetingToken]([bookingId]) WHERE [bookingId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[BookingReference] (
    [id] INT NOT NULL IDENTITY(1,1),
    [type] NVARCHAR(1000) NOT NULL,
    [uid] NVARCHAR(1000) NOT NULL,
    [meetingId] NVARCHAR(max),
    [thirdPartyRecurringEventId] NVARCHAR(max),
    [meetingPassword] NVARCHAR(max),
    [meetingUrl] NVARCHAR(max),
    [bookingId] INT,
    [externalCalendarId] NVARCHAR(max),
    [deleted] BIT,
    [credentialId] INT,
    [delegationCredentialId] NVARCHAR(1000),
    CONSTRAINT [BookingReference_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Attendee] (
    [id] INT NOT NULL IDENTITY(1,1),
    [email] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [timeZone] NVARCHAR(max) NOT NULL,
    [phoneNumber] NVARCHAR(max),
    [locale] NVARCHAR(max) CONSTRAINT [Attendee_locale_df] DEFAULT 'en',
    [bookingId] INT,
    [noShow] BIT CONSTRAINT [Attendee_noShow_df] DEFAULT 0,
    CONSTRAINT [Attendee_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Booking] (
    [id] INT NOT NULL IDENTITY(1,1),
    [uid] NVARCHAR(1000) NOT NULL,
    [idempotencyKey] NVARCHAR(1000),
    [userId] INT,
    [userPrimaryEmail] NVARCHAR(max),
    [eventTypeId] INT,
    [title] NVARCHAR(max) NOT NULL,
    [description] NVARCHAR(max),
    [customInputs] NVARCHAR(max),
    [responses] NVARCHAR(max),
    [startTime] DATETIME2 NOT NULL,
    [endTime] DATETIME2 NOT NULL,
    [location] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Booking_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2,
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [Booking_status_df] DEFAULT 'ACCEPTED',
    [paid] BIT NOT NULL CONSTRAINT [Booking_paid_df] DEFAULT 0,
    [destinationCalendarId] INT,
    [cancellationReason] NVARCHAR(max),
    [rejectionReason] NVARCHAR(max),
    [reassignReason] NVARCHAR(max),
    [reassignById] INT,
    [dynamicEventSlugRef] NVARCHAR(max),
    [dynamicGroupSlugRef] NVARCHAR(max),
    [rescheduled] BIT,
    [fromReschedule] NVARCHAR(1000),
    [recurringEventId] NVARCHAR(1000),
    [smsReminderNumber] NVARCHAR(max),
    [scheduledJobs] NVARCHAR(max) NOT NULL CONSTRAINT [Booking_scheduledJobs_df] DEFAULT '[]',
    [metadata] NVARCHAR(max),
    [isRecorded] BIT NOT NULL CONSTRAINT [Booking_isRecorded_df] DEFAULT 0,
    [iCalUID] NVARCHAR(max) CONSTRAINT [Booking_iCalUID_df] DEFAULT '',
    [iCalSequence] INT NOT NULL CONSTRAINT [Booking_iCalSequence_df] DEFAULT 0,
    [rating] INT,
    [ratingFeedback] NVARCHAR(max),
    [noShowHost] BIT CONSTRAINT [Booking_noShowHost_df] DEFAULT 0,
    [oneTimePassword] NVARCHAR(1000),
    [cancelledBy] NVARCHAR(max),
    [rescheduledBy] NVARCHAR(max),
    [creationSource] NVARCHAR(100),
    CONSTRAINT [Booking_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Booking_uid_key] UNIQUE NONCLUSTERED ([uid])
);

CREATE UNIQUE NONCLUSTERED INDEX [Booking_idempotencyKey_key] ON [dbo].[Booking]([idempotencyKey]) WHERE [idempotencyKey] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [Booking_oneTimePassword_key] ON [dbo].[Booking]([oneTimePassword]) WHERE [oneTimePassword] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[Tracking] (
    [id] INT NOT NULL IDENTITY(1,1),
    [bookingId] INT NOT NULL,
    [utm_source] NVARCHAR(max),
    [utm_medium] NVARCHAR(max),
    [utm_campaign] NVARCHAR(max),
    [utm_term] NVARCHAR(max),
    [utm_content] NVARCHAR(max),
    CONSTRAINT [Tracking_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Tracking_bookingId_key] UNIQUE NONCLUSTERED ([bookingId])
);

-- CreateTable
CREATE TABLE [dbo].[Schedule] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [timeZone] NVARCHAR(max),
    CONSTRAINT [Schedule_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Availability] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT,
    [eventTypeId] INT,
    [days] NVARCHAR(max) NOT NULL CONSTRAINT [Availability_days_df] DEFAULT '[]',
    [startTime] TIME NOT NULL,
    [endTime] TIME NOT NULL,
    [date] DATE,
    [scheduleId] INT,
    CONSTRAINT [Availability_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[SelectedCalendar] (
    [id] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [integration] NVARCHAR(1000) NOT NULL,
    [externalId] NVARCHAR(1000) NOT NULL,
    [credentialId] INT,
    [createdAt] DATETIME2 CONSTRAINT [SelectedCalendar_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2,
    [googleChannelId] NVARCHAR(1000),
    [googleChannelKind] NVARCHAR(max),
    [googleChannelResourceId] NVARCHAR(max),
    [googleChannelResourceUri] NVARCHAR(max),
    [googleChannelExpiration] NVARCHAR(1000),
    [channelId] NVARCHAR(1000),
    [channelKind] NVARCHAR(max),
    [channelResourceId] NVARCHAR(max),
    [channelResourceUri] NVARCHAR(max),
    [channelExpiration] DATETIME2,
    [syncSubscribedAt] DATETIME2,
    [syncSubscribedErrorAt] DATETIME2,
    [syncSubscribedErrorCount] INT NOT NULL CONSTRAINT [SelectedCalendar_syncSubscribedErrorCount_df] DEFAULT 0,
    [syncToken] NVARCHAR(max),
    [syncedAt] DATETIME2,
    [syncErrorAt] DATETIME2,
    [syncErrorCount] INT CONSTRAINT [SelectedCalendar_syncErrorCount_df] DEFAULT 0,
    [delegationCredentialId] NVARCHAR(1000),
    [error] NVARCHAR(1000),
    [lastErrorAt] DATETIME2,
    [watchAttempts] INT NOT NULL CONSTRAINT [SelectedCalendar_watchAttempts_df] DEFAULT 0,
    [unwatchAttempts] INT NOT NULL CONSTRAINT [SelectedCalendar_unwatchAttempts_df] DEFAULT 0,
    [maxAttempts] INT NOT NULL CONSTRAINT [SelectedCalendar_maxAttempts_df] DEFAULT 3,
    [eventTypeId] INT,
    CONSTRAINT [SelectedCalendar_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [SelectedCalendar_userId_integration_externalId_eventTypeId_key] ON [dbo].[SelectedCalendar]([userId],[integration],[externalId],[eventTypeId]) WHERE [eventTypeId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [SelectedCalendar_googleChannelId_eventTypeId_key] ON [dbo].[SelectedCalendar]([googleChannelId],[eventTypeId]) WHERE [googleChannelId] IS NOT NULL AND [eventTypeId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[EventTypeCustomInput] (
    [id] INT NOT NULL IDENTITY(1,1),
    [eventTypeId] INT NOT NULL,
    [label] NVARCHAR(max) NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [options] NVARCHAR(max),
    [required] BIT NOT NULL,
    [placeholder] NVARCHAR(max) NOT NULL CONSTRAINT [EventTypeCustomInput_placeholder_df] DEFAULT '',
    CONSTRAINT [EventTypeCustomInput_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[ResetPasswordRequest] (
    [id] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ResetPasswordRequest_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [email] NVARCHAR(max) NOT NULL,
    [expires] DATETIME2 NOT NULL,
    CONSTRAINT [ResetPasswordRequest_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[ReminderMail] (
    [id] INT NOT NULL IDENTITY(1,1),
    [referenceId] INT NOT NULL,
    [reminderType] NVARCHAR(100) NOT NULL,
    [elapsedMinutes] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ReminderMail_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [ReminderMail_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Payment] (
    [id] INT NOT NULL IDENTITY(1,1),
    [uid] NVARCHAR(1000) NOT NULL,
    [appId] NVARCHAR(1000),
    [bookingId] INT NOT NULL,
    [amount] INT NOT NULL,
    [fee] INT NOT NULL,
    [currency] NVARCHAR(max) NOT NULL,
    [success] BIT NOT NULL,
    [refunded] BIT NOT NULL,
    [data] NVARCHAR(max) NOT NULL,
    [externalId] NVARCHAR(1000) NOT NULL,
    [paymentOption] NVARCHAR(100) CONSTRAINT [Payment_paymentOption_df] DEFAULT 'ON_BOOKING',
    CONSTRAINT [Payment_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Payment_uid_key] UNIQUE NONCLUSTERED ([uid]),
    CONSTRAINT [Payment_externalId_key] UNIQUE NONCLUSTERED ([externalId])
);

-- CreateTable
CREATE TABLE [dbo].[Webhook] (
    [id] NVARCHAR(1000) NOT NULL,
    [userId] INT,
    [teamId] INT,
    [eventTypeId] INT,
    [platformOAuthClientId] NVARCHAR(1000),
    [subscriberUrl] NVARCHAR(1000) NOT NULL,
    [payloadTemplate] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Webhook_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [active] BIT NOT NULL CONSTRAINT [Webhook_active_df] DEFAULT 1,
    [eventTriggers] NVARCHAR(max) NOT NULL CONSTRAINT [Webhook_eventTriggers_df] DEFAULT '[]',
    [appId] NVARCHAR(1000),
    [secret] NVARCHAR(max),
    [platform] BIT NOT NULL CONSTRAINT [Webhook_platform_df] DEFAULT 0,
    [time] INT,
    [timeUnit] NVARCHAR(100),
    [version] NVARCHAR(max) NOT NULL CONSTRAINT [Webhook_version_df] DEFAULT '2021-10-20',
    CONSTRAINT [Webhook_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Webhook_id_key] UNIQUE NONCLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [Webhook_userId_subscriberUrl_key] ON [dbo].[Webhook]([userId],[subscriberUrl]) WHERE [userId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [Webhook_platformOAuthClientId_subscriberUrl_key] ON [dbo].[Webhook]([platformOAuthClientId],[subscriberUrl]) WHERE [platformOAuthClientId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[ApiKey] (
    [id] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [teamId] INT,
    [note] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ApiKey_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [expiresAt] DATETIME2,
    [lastUsedAt] DATETIME2,
    [hashedKey] NVARCHAR(1000) NOT NULL,
    [appId] NVARCHAR(1000),
    CONSTRAINT [ApiKey_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [ApiKey_id_key] UNIQUE NONCLUSTERED ([id]),
    CONSTRAINT [ApiKey_hashedKey_key] UNIQUE NONCLUSTERED ([hashedKey])
);

-- CreateTable
CREATE TABLE [dbo].[RateLimit] (
    [id] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [apiKeyId] NVARCHAR(1000) NOT NULL,
    [ttl] INT NOT NULL,
    [limit] INT NOT NULL,
    [blockDuration] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [RateLimit_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [RateLimit_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[HashedLink] (
    [id] INT NOT NULL IDENTITY(1,1),
    [link] NVARCHAR(1000) NOT NULL,
    [eventTypeId] INT NOT NULL,
    [expiresAt] DATETIME2,
    [maxUsageCount] INT NOT NULL CONSTRAINT [HashedLink_maxUsageCount_df] DEFAULT 1,
    [usageCount] INT NOT NULL CONSTRAINT [HashedLink_usageCount_df] DEFAULT 0,
    CONSTRAINT [HashedLink_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [HashedLink_link_key] UNIQUE NONCLUSTERED ([link])
);

-- CreateTable
CREATE TABLE [dbo].[Account] (
    [id] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [type] NVARCHAR(1000) NOT NULL,
    [provider] NVARCHAR(1000) NOT NULL,
    [providerAccountId] NVARCHAR(1000) NOT NULL,
    [providerEmail] NVARCHAR(max),
    [refresh_token] NVARCHAR(max),
    [access_token] NVARCHAR(max),
    [expires_at] INT,
    [token_type] NVARCHAR(max),
    [scope] NVARCHAR(max),
    [id_token] NVARCHAR(max),
    [session_state] NVARCHAR(max),
    CONSTRAINT [Account_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Account_provider_providerAccountId_key] UNIQUE NONCLUSTERED ([provider],[providerAccountId])
);

-- CreateTable
CREATE TABLE [dbo].[Session] (
    [id] NVARCHAR(1000) NOT NULL,
    [sessionToken] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [expires] DATETIME2 NOT NULL,
    CONSTRAINT [Session_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Session_sessionToken_key] UNIQUE NONCLUSTERED ([sessionToken])
);

-- CreateTable
CREATE TABLE [dbo].[App] (
    [slug] NVARCHAR(1000) NOT NULL,
    [dirName] NVARCHAR(1000) NOT NULL,
    [keys] NVARCHAR(max),
    [categories] NVARCHAR(max) NOT NULL CONSTRAINT [App_categories_df] DEFAULT '[]',
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [App_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [App_enabled_df] DEFAULT 0,
    CONSTRAINT [App_pkey] PRIMARY KEY CLUSTERED ([slug]),
    CONSTRAINT [App_slug_key] UNIQUE NONCLUSTERED ([slug]),
    CONSTRAINT [App_dirName_key] UNIQUE NONCLUSTERED ([dirName])
);

-- CreateTable
CREATE TABLE [dbo].[Feedback] (
    [id] INT NOT NULL IDENTITY(1,1),
    [date] DATETIME2 NOT NULL CONSTRAINT [Feedback_date_df] DEFAULT CURRENT_TIMESTAMP,
    [userId] INT NOT NULL,
    [rating] NVARCHAR(1000) NOT NULL,
    [comment] NVARCHAR(max),
    CONSTRAINT [Feedback_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Deployment] (
    [id] INT NOT NULL CONSTRAINT [Deployment_id_df] DEFAULT 1,
    [logo] NVARCHAR(max),
    [theme] NVARCHAR(max),
    [licenseKey] NVARCHAR(max),
    [signatureTokenEncrypted] NVARCHAR(max),
    [agreedLicenseAt] DATETIME2,
    CONSTRAINT [Deployment_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[WebhookScheduledTriggers] (
    [id] INT NOT NULL IDENTITY(1,1),
    [jobName] NVARCHAR(max),
    [subscriberUrl] NVARCHAR(max) NOT NULL,
    [payload] NVARCHAR(max) NOT NULL,
    [startAfter] DATETIME2 NOT NULL,
    [retryCount] INT NOT NULL CONSTRAINT [WebhookScheduledTriggers_retryCount_df] DEFAULT 0,
    [createdAt] DATETIME2 CONSTRAINT [WebhookScheduledTriggers_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [appId] NVARCHAR(max),
    [webhookId] NVARCHAR(1000),
    [bookingId] INT,
    CONSTRAINT [WebhookScheduledTriggers_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[BookingSeat] (
    [id] INT NOT NULL IDENTITY(1,1),
    [referenceUid] NVARCHAR(1000) NOT NULL,
    [bookingId] INT NOT NULL,
    [attendeeId] INT NOT NULL,
    [data] NVARCHAR(max),
    [metadata] NVARCHAR(max),
    CONSTRAINT [BookingSeat_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [BookingSeat_referenceUid_key] UNIQUE NONCLUSTERED ([referenceUid]),
    CONSTRAINT [BookingSeat_attendeeId_key] UNIQUE NONCLUSTERED ([attendeeId])
);

-- CreateTable
CREATE TABLE [dbo].[VerifiedNumber] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT,
    [teamId] INT,
    [phoneNumber] NVARCHAR(max) NOT NULL,
    CONSTRAINT [VerifiedNumber_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[VerifiedEmail] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT,
    [teamId] INT,
    [email] NVARCHAR(max) NOT NULL,
    CONSTRAINT [VerifiedEmail_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Feature] (
    [slug] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [Feature_enabled_df] DEFAULT 0,
    [description] NVARCHAR(max),
    [type] NVARCHAR(100) CONSTRAINT [Feature_type_df] DEFAULT 'RELEASE',
    [stale] BIT CONSTRAINT [Feature_stale_df] DEFAULT 0,
    [lastUsedAt] DATETIME2,
    [createdAt] DATETIME2 CONSTRAINT [Feature_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 CONSTRAINT [Feature_updatedAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedBy] INT,
    CONSTRAINT [Feature_pkey] PRIMARY KEY CLUSTERED ([slug]),
    CONSTRAINT [Feature_slug_key] UNIQUE NONCLUSTERED ([slug])
);

-- CreateTable
CREATE TABLE [dbo].[UserFeatures] (
    [userId] INT NOT NULL,
    [featureId] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL,
    [assignedAt] DATETIME2 NOT NULL CONSTRAINT [UserFeatures_assignedAt_df] DEFAULT CURRENT_TIMESTAMP,
    [assignedBy] NVARCHAR(max) NOT NULL,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [UserFeatures_pkey] PRIMARY KEY CLUSTERED ([userId],[featureId])
);

-- CreateTable
CREATE TABLE [dbo].[TeamFeatures] (
    [teamId] INT NOT NULL,
    [featureId] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL,
    [assignedAt] DATETIME2 NOT NULL CONSTRAINT [TeamFeatures_assignedAt_df] DEFAULT CURRENT_TIMESTAMP,
    [assignedBy] NVARCHAR(max) NOT NULL,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [TeamFeatures_pkey] PRIMARY KEY CLUSTERED ([teamId],[featureId])
);

-- CreateTable
CREATE TABLE [dbo].[SelectedSlots] (
    [id] INT NOT NULL IDENTITY(1,1),
    [eventTypeId] INT NOT NULL,
    [userId] INT NOT NULL,
    [slotUtcStartDate] DATETIME2 NOT NULL,
    [slotUtcEndDate] DATETIME2 NOT NULL,
    [uid] NVARCHAR(1000) NOT NULL,
    [releaseAt] DATETIME2 NOT NULL,
    [isSeat] BIT NOT NULL CONSTRAINT [SelectedSlots_isSeat_df] DEFAULT 0,
    CONSTRAINT [SelectedSlots_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [SelectedSlots_userId_slotUtcStartDate_slotUtcEndDate_uid_key] UNIQUE NONCLUSTERED ([userId],[slotUtcStartDate],[slotUtcEndDate],[uid])
);

-- CreateTable
CREATE TABLE [dbo].[OAuthClient] (
    [clientId] NVARCHAR(1000) NOT NULL,
    [redirectUri] NVARCHAR(max) NOT NULL,
    [clientSecret] NVARCHAR(max),
    [clientType] NVARCHAR(100) NOT NULL CONSTRAINT [OAuthClient_clientType_df] DEFAULT 'CONFIDENTIAL',
    [name] NVARCHAR(max) NOT NULL,
    [purpose] NVARCHAR(max),
    [logo] NVARCHAR(max),
    [websiteUrl] NVARCHAR(max),
    [rejectionReason] NVARCHAR(max),
    [isTrusted] BIT NOT NULL CONSTRAINT [OAuthClient_isTrusted_df] DEFAULT 0,
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [OAuthClient_status_df] DEFAULT 'APPROVED',
    [userId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [OAuthClient_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [OAuthClient_pkey] PRIMARY KEY CLUSTERED ([clientId]),
    CONSTRAINT [OAuthClient_clientId_key] UNIQUE NONCLUSTERED ([clientId])
);

-- CreateTable
CREATE TABLE [dbo].[AccessCode] (
    [id] INT NOT NULL IDENTITY(1,1),
    [code] NVARCHAR(max) NOT NULL,
    [clientId] NVARCHAR(1000),
    [expiresAt] DATETIME2 NOT NULL,
    [scopes] NVARCHAR(max) NOT NULL CONSTRAINT [AccessCode_scopes_df] DEFAULT '[]',
    [userId] INT,
    [teamId] INT,
    [codeChallenge] NVARCHAR(max),
    [codeChallengeMethod] NVARCHAR(max) CONSTRAINT [AccessCode_codeChallengeMethod_df] DEFAULT 'S256',
    CONSTRAINT [AccessCode_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[BookingDenormalized] (
    [id] INT NOT NULL,
    [uid] NVARCHAR(max) NOT NULL,
    [eventTypeId] INT,
    [title] NVARCHAR(max) NOT NULL,
    [description] NVARCHAR(max),
    [startTime] DATETIME2 NOT NULL,
    [endTime] DATETIME2 NOT NULL,
    [createdAt] DATETIME2 NOT NULL,
    [updatedAt] DATETIME2,
    [location] NVARCHAR(max),
    [paid] BIT NOT NULL,
    [status] NVARCHAR(100) NOT NULL,
    [rescheduled] BIT,
    [userId] INT,
    [teamId] INT,
    [eventLength] INT,
    [eventParentId] INT,
    [userEmail] NVARCHAR(max),
    [userName] NVARCHAR(max),
    [userUsername] NVARCHAR(max),
    [ratingFeedback] NVARCHAR(max),
    [rating] INT,
    [noShowHost] BIT,
    [isTeamBooking] BIT NOT NULL,
    CONSTRAINT [BookingDenormalized_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [BookingDenormalized_id_key] UNIQUE NONCLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[CalendarCache] (
    [id] NVARCHAR(max),
    [key] NVARCHAR(1000) NOT NULL,
    [value] NVARCHAR(max) NOT NULL,
    [expiresAt] DATETIME2 NOT NULL,
    [updatedAt] DATETIME2 NOT NULL CONSTRAINT [CalendarCache_updatedAt_df] DEFAULT CURRENT_TIMESTAMP,
    [credentialId] INT NOT NULL,
    [userId] INT,
    CONSTRAINT [CalendarCache_pkey] PRIMARY KEY CLUSTERED ([credentialId],[key]),
    CONSTRAINT [CalendarCache_credentialId_key_key] UNIQUE NONCLUSTERED ([credentialId],[key])
);

-- CreateTable
CREATE TABLE [dbo].[TempOrgRedirect] (
    [id] INT NOT NULL IDENTITY(1,1),
    [from] NVARCHAR(1000) NOT NULL,
    [fromOrgId] INT NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [toUrl] NVARCHAR(max) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [TempOrgRedirect_enabled_df] DEFAULT 1,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [TempOrgRedirect_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [TempOrgRedirect_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [TempOrgRedirect_from_type_fromOrgId_key] UNIQUE NONCLUSTERED ([from],[type],[fromOrgId])
);

-- CreateTable
CREATE TABLE [dbo].[avatars] (
    [teamId] INT NOT NULL CONSTRAINT [avatars_teamId_df] DEFAULT 0,
    [userId] INT NOT NULL CONSTRAINT [avatars_userId_df] DEFAULT 0,
    [data] NVARCHAR(max) NOT NULL,
    [objectKey] NVARCHAR(1000) NOT NULL,
    [isBanner] BIT NOT NULL CONSTRAINT [avatars_isBanner_df] DEFAULT 0,
    CONSTRAINT [avatars_objectKey_key] UNIQUE NONCLUSTERED ([objectKey]),
    CONSTRAINT [avatars_teamId_userId_isBanner_key] UNIQUE NONCLUSTERED ([teamId],[userId],[isBanner])
);

-- CreateTable
CREATE TABLE [dbo].[OutOfOfficeEntry] (
    [id] INT NOT NULL IDENTITY(1,1),
    [uuid] NVARCHAR(1000) NOT NULL,
    [start] DATETIME2 NOT NULL,
    [end] DATETIME2 NOT NULL,
    [notes] NVARCHAR(max),
    [showNotePublicly] BIT NOT NULL CONSTRAINT [OutOfOfficeEntry_showNotePublicly_df] DEFAULT 0,
    [userId] INT NOT NULL,
    [toUserId] INT,
    [reasonId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [OutOfOfficeEntry_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [OutOfOfficeEntry_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [OutOfOfficeEntry_uuid_key] UNIQUE NONCLUSTERED ([uuid])
);

-- CreateTable
CREATE TABLE [dbo].[OutOfOfficeReason] (
    [id] INT NOT NULL IDENTITY(1,1),
    [emoji] NVARCHAR(max) NOT NULL,
    [reason] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [OutOfOfficeReason_enabled_df] DEFAULT 1,
    [userId] INT,
    CONSTRAINT [OutOfOfficeReason_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [OutOfOfficeReason_reason_key] UNIQUE NONCLUSTERED ([reason])
);

-- CreateTable
CREATE TABLE [dbo].[UserHolidaySettings] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [countryCode] NVARCHAR(max),
    [disabledIds] NVARCHAR(max) NOT NULL CONSTRAINT [UserHolidaySettings_disabledIds_df] DEFAULT '[]',
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [UserHolidaySettings_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [UserHolidaySettings_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [UserHolidaySettings_userId_key] UNIQUE NONCLUSTERED ([userId])
);

-- CreateTable
CREATE TABLE [dbo].[HolidayCache] (
    [id] NVARCHAR(1000) NOT NULL,
    [countryCode] NVARCHAR(1000) NOT NULL,
    [calendarId] NVARCHAR(max) NOT NULL,
    [eventId] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [date] DATETIME2 NOT NULL,
    [year] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [HolidayCache_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [HolidayCache_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [HolidayCache_countryCode_eventId_key] UNIQUE NONCLUSTERED ([countryCode],[eventId])
);

-- CreateTable
CREATE TABLE [dbo].[PlatformOAuthClient] (
    [id] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [secret] NVARCHAR(max) NOT NULL,
    [permissions] INT NOT NULL,
    [logo] NVARCHAR(max),
    [redirectUris] NVARCHAR(max) NOT NULL CONSTRAINT [PlatformOAuthClient_redirectUris_df] DEFAULT '[]',
    [organizationId] INT NOT NULL,
    [bookingRedirectUri] NVARCHAR(max),
    [bookingCancelRedirectUri] NVARCHAR(max),
    [bookingRescheduleRedirectUri] NVARCHAR(max),
    [areEmailsEnabled] BIT NOT NULL CONSTRAINT [PlatformOAuthClient_areEmailsEnabled_df] DEFAULT 0,
    [areDefaultEventTypesEnabled] BIT NOT NULL CONSTRAINT [PlatformOAuthClient_areDefaultEventTypesEnabled_df] DEFAULT 1,
    [areCalendarEventsEnabled] BIT NOT NULL CONSTRAINT [PlatformOAuthClient_areCalendarEventsEnabled_df] DEFAULT 1,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [PlatformOAuthClient_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [PlatformOAuthClient_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[PlatformAuthorizationToken] (
    [id] NVARCHAR(1000) NOT NULL,
    [platformOAuthClientId] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [PlatformAuthorizationToken_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [PlatformAuthorizationToken_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [PlatformAuthorizationToken_userId_platformOAuthClientId_key] UNIQUE NONCLUSTERED ([userId],[platformOAuthClientId])
);

-- CreateTable
CREATE TABLE [dbo].[AccessToken] (
    [id] INT NOT NULL IDENTITY(1,1),
    [secret] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AccessToken_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [expiresAt] DATETIME2 NOT NULL,
    [platformOAuthClientId] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    CONSTRAINT [AccessToken_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [AccessToken_secret_key] UNIQUE NONCLUSTERED ([secret])
);

-- CreateTable
CREATE TABLE [dbo].[RefreshToken] (
    [id] INT NOT NULL IDENTITY(1,1),
    [secret] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [RefreshToken_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [expiresAt] DATETIME2 NOT NULL,
    [platformOAuthClientId] NVARCHAR(1000) NOT NULL,
    [userId] INT NOT NULL,
    CONSTRAINT [RefreshToken_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [RefreshToken_secret_key] UNIQUE NONCLUSTERED ([secret])
);

-- CreateTable
CREATE TABLE [dbo].[DSyncData] (
    [id] INT NOT NULL IDENTITY(1,1),
    [directoryId] NVARCHAR(1000) NOT NULL,
    [tenant] NVARCHAR(max) NOT NULL,
    [organizationId] INT,
    CONSTRAINT [DSyncData_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DSyncData_directoryId_key] UNIQUE NONCLUSTERED ([directoryId])
);

CREATE UNIQUE NONCLUSTERED INDEX [DSyncData_organizationId_key] ON [dbo].[DSyncData]([organizationId]) WHERE [organizationId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[DSyncTeamGroupMapping] (
    [id] INT NOT NULL IDENTITY(1,1),
    [organizationId] INT NOT NULL,
    [teamId] INT NOT NULL,
    [directoryId] NVARCHAR(1000) NOT NULL,
    [groupName] NVARCHAR(1000) NOT NULL,
    CONSTRAINT [DSyncTeamGroupMapping_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DSyncTeamGroupMapping_teamId_groupName_key] UNIQUE NONCLUSTERED ([teamId],[groupName])
);

-- CreateTable
CREATE TABLE [dbo].[SecondaryEmail] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [email] NVARCHAR(1000) NOT NULL,
    [emailVerified] DATETIME2,
    CONSTRAINT [SecondaryEmail_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [SecondaryEmail_email_key] UNIQUE NONCLUSTERED ([email]),
    CONSTRAINT [SecondaryEmail_userId_email_key] UNIQUE NONCLUSTERED ([userId],[email])
);

-- CreateTable
CREATE TABLE [dbo].[Task] (
    [id] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Task_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [scheduledAt] DATETIME2 NOT NULL CONSTRAINT [Task_scheduledAt_df] DEFAULT CURRENT_TIMESTAMP,
    [succeededAt] DATETIME2,
    [type] NVARCHAR(1000) NOT NULL,
    [payload] NVARCHAR(max) NOT NULL,
    [attempts] INT NOT NULL CONSTRAINT [Task_attempts_df] DEFAULT 0,
    [maxAttempts] INT NOT NULL CONSTRAINT [Task_maxAttempts_df] DEFAULT 3,
    [lastError] NVARCHAR(max),
    [lastFailedAttemptAt] DATETIME2,
    [referenceUid] NVARCHAR(1000),
    CONSTRAINT [Task_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Task_id_key] UNIQUE NONCLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [Task_referenceUid_type_key] ON [dbo].[Task]([referenceUid],[type]) WHERE [referenceUid] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[ManagedOrganization] (
    [managedOrganizationId] INT NOT NULL,
    [managerOrganizationId] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ManagedOrganization_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [ManagedOrganization_managedOrganizationId_key] UNIQUE NONCLUSTERED ([managedOrganizationId]),
    CONSTRAINT [ManagedOrganization_managerOrganizationId_managedOrganizationId_key] UNIQUE NONCLUSTERED ([managerOrganizationId],[managedOrganizationId])
);

-- CreateTable
CREATE TABLE [dbo].[PlatformBilling] (
    [id] INT NOT NULL,
    [customerId] NVARCHAR(max) NOT NULL,
    [subscriptionId] NVARCHAR(max),
    [priceId] NVARCHAR(max),
    [plan] NVARCHAR(max) NOT NULL CONSTRAINT [PlatformBilling_plan_df] DEFAULT 'none',
    [billingCycleStart] INT,
    [billingCycleEnd] INT,
    [overdue] BIT CONSTRAINT [PlatformBilling_overdue_df] DEFAULT 0,
    [managerBillingId] INT,
    CONSTRAINT [PlatformBilling_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [PlatformBilling_id_key] UNIQUE NONCLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[AttributeOption] (
    [id] NVARCHAR(1000) NOT NULL,
    [attributeId] NVARCHAR(1000) NOT NULL,
    [value] NVARCHAR(max) NOT NULL,
    [slug] NVARCHAR(max) NOT NULL,
    [isGroup] BIT NOT NULL CONSTRAINT [AttributeOption_isGroup_df] DEFAULT 0,
    [contains] NVARCHAR(max) NOT NULL CONSTRAINT [AttributeOption_contains_df] DEFAULT '[]',
    CONSTRAINT [AttributeOption_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Attribute] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [slug] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [Attribute_enabled_df] DEFAULT 1,
    [usersCanEditRelation] BIT NOT NULL CONSTRAINT [Attribute_usersCanEditRelation_df] DEFAULT 0,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Attribute_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [isWeightsEnabled] BIT NOT NULL CONSTRAINT [Attribute_isWeightsEnabled_df] DEFAULT 0,
    [isLocked] BIT NOT NULL CONSTRAINT [Attribute_isLocked_df] DEFAULT 0,
    CONSTRAINT [Attribute_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Attribute_teamId_slug_key] UNIQUE NONCLUSTERED ([teamId],[slug])
);

-- CreateTable
CREATE TABLE [dbo].[AttributeToUser] (
    [id] NVARCHAR(1000) NOT NULL,
    [memberId] INT NOT NULL,
    [attributeOptionId] NVARCHAR(1000) NOT NULL,
    [weight] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AttributeToUser_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [createdById] INT,
    [createdByDSyncId] NVARCHAR(1000),
    [updatedAt] DATETIME2,
    [updatedById] INT,
    [updatedByDSyncId] NVARCHAR(1000),
    CONSTRAINT [AttributeToUser_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [AttributeToUser_memberId_attributeOptionId_key] UNIQUE NONCLUSTERED ([memberId],[attributeOptionId])
);

-- CreateTable
CREATE TABLE [dbo].[AssignmentReason] (
    [id] INT NOT NULL IDENTITY(1,1),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AssignmentReason_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [bookingId] INT NOT NULL,
    [reasonEnum] NVARCHAR(100) NOT NULL,
    [reasonString] NVARCHAR(max) NOT NULL,
    CONSTRAINT [AssignmentReason_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [AssignmentReason_id_key] UNIQUE NONCLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[DelegationCredential] (
    [id] NVARCHAR(1000) NOT NULL,
    [workspacePlatformId] INT NOT NULL,
    [serviceAccountKey] NVARCHAR(max) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [DelegationCredential_enabled_df] DEFAULT 0,
    [lastEnabledAt] DATETIME2,
    [lastDisabledAt] DATETIME2,
    [organizationId] INT NOT NULL,
    [domain] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [DelegationCredential_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [DelegationCredential_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DelegationCredential_organizationId_domain_key] UNIQUE NONCLUSTERED ([organizationId],[domain])
);

-- CreateTable
CREATE TABLE [dbo].[WorkspacePlatform] (
    [id] INT NOT NULL IDENTITY(1,1),
    [slug] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [description] NVARCHAR(max) NOT NULL,
    [defaultServiceAccountKey] NVARCHAR(max) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [WorkspacePlatform_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [WorkspacePlatform_enabled_df] DEFAULT 0,
    CONSTRAINT [WorkspacePlatform_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [WorkspacePlatform_slug_key] UNIQUE NONCLUSTERED ([slug])
);

-- CreateTable
CREATE TABLE [dbo].[EventTypeTranslation] (
    [uid] NVARCHAR(1000) NOT NULL,
    [eventTypeId] INT NOT NULL,
    [field] NVARCHAR(100) NOT NULL,
    [sourceLocale] NVARCHAR(max) NOT NULL,
    [targetLocale] NVARCHAR(1000) NOT NULL,
    [translatedText] NVARCHAR(max) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [EventTypeTranslation_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [createdBy] INT NOT NULL,
    [updatedAt] DATETIME2 NOT NULL,
    [updatedBy] INT,
    CONSTRAINT [EventTypeTranslation_pkey] PRIMARY KEY CLUSTERED ([uid]),
    CONSTRAINT [EventTypeTranslation_eventTypeId_field_targetLocale_key] UNIQUE NONCLUSTERED ([eventTypeId],[field],[targetLocale])
);

-- CreateTable
CREATE TABLE [dbo].[Watchlist] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [value] NVARCHAR(1000) NOT NULL,
    [description] NVARCHAR(max),
    [isGlobal] BIT NOT NULL CONSTRAINT [Watchlist_isGlobal_df] DEFAULT 0,
    [organizationId] INT,
    [action] NVARCHAR(100) NOT NULL CONSTRAINT [Watchlist_action_df] DEFAULT 'REPORT',
    [source] NVARCHAR(100) NOT NULL CONSTRAINT [Watchlist_source_df] DEFAULT 'MANUAL',
    [lastUpdatedAt] DATETIME2 NOT NULL CONSTRAINT [Watchlist_lastUpdatedAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [Watchlist_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [Watchlist_type_value_organizationId_key] ON [dbo].[Watchlist]([type],[value],[organizationId]) WHERE [organizationId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[WatchlistAudit] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [value] NVARCHAR(max) NOT NULL,
    [description] NVARCHAR(max),
    [action] NVARCHAR(100) NOT NULL CONSTRAINT [WatchlistAudit_action_df] DEFAULT 'REPORT',
    [changedAt] DATETIME2 NOT NULL CONSTRAINT [WatchlistAudit_changedAt_df] DEFAULT CURRENT_TIMESTAMP,
    [changedByUserId] INT,
    [watchlistId] UNIQUEIDENTIFIER,
    CONSTRAINT [WatchlistAudit_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[WatchlistEventAudit] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [watchlistId] UNIQUEIDENTIFIER NOT NULL,
    [eventTypeId] INT NOT NULL,
    [actionTaken] NVARCHAR(100) NOT NULL,
    [timestamp] DATETIME2 NOT NULL CONSTRAINT [WatchlistEventAudit_timestamp_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [WatchlistEventAudit_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[BookingReport] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [bookingUid] NVARCHAR(1000) NOT NULL,
    [bookerEmail] NVARCHAR(1000) NOT NULL,
    [reportedById] INT,
    [organizationId] INT,
    [reason] NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(max),
    [cancelled] BIT NOT NULL CONSTRAINT [BookingReport_cancelled_df] DEFAULT 0,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [BookingReport_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [BookingReport_status_df] DEFAULT 'PENDING',
    [systemStatus] NVARCHAR(100) NOT NULL CONSTRAINT [BookingReport_systemStatus_df] DEFAULT 'PENDING',
    [watchlistId] UNIQUEIDENTIFIER,
    [globalWatchlistId] UNIQUEIDENTIFIER,
    CONSTRAINT [BookingReport_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [BookingReport_bookingUid_key] UNIQUE NONCLUSTERED ([bookingUid])
);

-- CreateTable
CREATE TABLE [dbo].[WrongAssignmentReport] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [bookingUid] NVARCHAR(1000) NOT NULL,
    [reportedById] INT,
    [correctAssignee] NVARCHAR(max),
    [additionalNotes] NVARCHAR(max) NOT NULL,
    [teamId] INT,
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [WrongAssignmentReport_status_df] DEFAULT 'PENDING',
    [reviewedById] INT,
    [reviewedAt] DATETIME2,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [WrongAssignmentReport_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [WrongAssignmentReport_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [WrongAssignmentReport_bookingUid_key] UNIQUE NONCLUSTERED ([bookingUid])
);

-- CreateTable
CREATE TABLE [dbo].[OrganizationOnboarding] (
    [id] NVARCHAR(1000) NOT NULL,
    [createdById] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [OrganizationOnboarding_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [orgOwnerEmail] NVARCHAR(1000) NOT NULL,
    [error] NVARCHAR(max),
    [updatedAt] DATETIME2 NOT NULL,
    [organizationId] INT,
    [billingPeriod] NVARCHAR(100) NOT NULL,
    [pricePerSeat] FLOAT(53) NOT NULL,
    [seats] INT NOT NULL,
    [isPlatform] BIT NOT NULL CONSTRAINT [OrganizationOnboarding_isPlatform_df] DEFAULT 0,
    [name] NVARCHAR(max) NOT NULL,
    [slug] NVARCHAR(max) NOT NULL,
    [logo] NVARCHAR(max),
    [bio] NVARCHAR(max),
    [brandColor] NVARCHAR(max),
    [bannerUrl] NVARCHAR(max),
    [isDomainConfigured] BIT NOT NULL CONSTRAINT [OrganizationOnboarding_isDomainConfigured_df] DEFAULT 0,
    [stripeCustomerId] NVARCHAR(1000),
    [stripeSubscriptionId] NVARCHAR(max),
    [stripeSubscriptionItemId] NVARCHAR(max),
    [invitedMembers] NVARCHAR(max) NOT NULL CONSTRAINT [OrganizationOnboarding_invitedMembers_df] DEFAULT '[]',
    [teams] NVARCHAR(max) NOT NULL CONSTRAINT [OrganizationOnboarding_teams_df] DEFAULT '[]',
    [isComplete] BIT NOT NULL CONSTRAINT [OrganizationOnboarding_isComplete_df] DEFAULT 0,
    CONSTRAINT [OrganizationOnboarding_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [OrganizationOnboarding_orgOwnerEmail_key] UNIQUE NONCLUSTERED ([orgOwnerEmail])
);

CREATE UNIQUE NONCLUSTERED INDEX [OrganizationOnboarding_organizationId_key] ON [dbo].[OrganizationOnboarding]([organizationId]) WHERE [organizationId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [OrganizationOnboarding_stripeCustomerId_key] ON [dbo].[OrganizationOnboarding]([stripeCustomerId]) WHERE [stripeCustomerId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[InternalNotePreset] (
    [id] INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(1000) NOT NULL,
    [cancellationReason] NVARCHAR(max),
    [teamId] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [InternalNotePreset_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [InternalNotePreset_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [InternalNotePreset_teamId_name_key] UNIQUE NONCLUSTERED ([teamId],[name])
);

-- CreateTable
CREATE TABLE [dbo].[FilterSegment] (
    [id] INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(max) NOT NULL,
    [tableIdentifier] NVARCHAR(1000) NOT NULL,
    [scope] NVARCHAR(100) NOT NULL,
    [activeFilters] NVARCHAR(max),
    [sorting] NVARCHAR(max),
    [columnVisibility] NVARCHAR(max),
    [columnSizing] NVARCHAR(max),
    [perPage] INT NOT NULL,
    [searchTerm] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [FilterSegment_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [userId] INT NOT NULL,
    [teamId] INT,
    CONSTRAINT [FilterSegment_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[UserFilterSegmentPreference] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [tableIdentifier] NVARCHAR(1000) NOT NULL,
    [segmentId] INT,
    [systemSegmentId] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [UserFilterSegmentPreference_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [UserFilterSegmentPreference_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [UserFilterSegmentPreference_userId_tableIdentifier_key] UNIQUE NONCLUSTERED ([userId],[tableIdentifier])
);

-- CreateTable
CREATE TABLE [dbo].[BookingInternalNote] (
    [id] INT NOT NULL IDENTITY(1,1),
    [notePresetId] INT,
    [text] NVARCHAR(max),
    [bookingId] INT NOT NULL,
    [createdById] INT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [BookingInternalNote_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [BookingInternalNote_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [BookingInternalNote_bookingId_notePresetId_key] ON [dbo].[BookingInternalNote]([bookingId],[notePresetId]) WHERE [notePresetId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[Role] (
    [id] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(1000) NOT NULL,
    [color] NVARCHAR(max),
    [description] NVARCHAR(max),
    [teamId] INT,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Role_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [type] NVARCHAR(100) NOT NULL CONSTRAINT [Role_type_df] DEFAULT 'CUSTOM',
    CONSTRAINT [Role_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [Role_name_teamId_key] ON [dbo].[Role]([name],[teamId]) WHERE [teamId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[RolePermission] (
    [id] NVARCHAR(1000) NOT NULL,
    [roleId] NVARCHAR(1000) NOT NULL,
    [resource] NVARCHAR(1000) NOT NULL,
    [action] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [RolePermission_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [RolePermission_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [RolePermission_roleId_resource_action_key] UNIQUE NONCLUSTERED ([roleId],[resource],[action])
);

-- CreateTable
CREATE TABLE [dbo].[AuditActor] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [userUuid] UNIQUEIDENTIFIER,
    [attendeeId] INT,
    [credentialId] INT,
    [email] NVARCHAR(1000),
    [phone] NVARCHAR(1000),
    [name] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AuditActor_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [AuditActor_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [AuditActor_userUuid_key] ON [dbo].[AuditActor]([userUuid]) WHERE [userUuid] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [AuditActor_attendeeId_key] ON [dbo].[AuditActor]([attendeeId]) WHERE [attendeeId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [AuditActor_credentialId_key] ON [dbo].[AuditActor]([credentialId]) WHERE [credentialId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [AuditActor_email_key] ON [dbo].[AuditActor]([email]) WHERE [email] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [AuditActor_phone_key] ON [dbo].[AuditActor]([phone]) WHERE [phone] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[BookingAudit] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [bookingUid] NVARCHAR(1000) NOT NULL,
    [actorId] UNIQUEIDENTIFIER NOT NULL,
    [type] NVARCHAR(100) NOT NULL,
    [action] NVARCHAR(100) NOT NULL,
    [timestamp] DATETIME2 NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [BookingAudit_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [source] NVARCHAR(100) NOT NULL,
    [operationId] NVARCHAR(1000) NOT NULL,
    [data] NVARCHAR(max),
    [context] NVARCHAR(max),
    CONSTRAINT [BookingAudit_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[Agent] (
    [id] NVARCHAR(1000) NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [userId] INT,
    [teamId] INT,
    [providerAgentId] NVARCHAR(1000) NOT NULL,
    [inboundEventTypeId] INT,
    [outboundEventTypeId] INT,
    [enabled] BIT NOT NULL CONSTRAINT [Agent_enabled_df] DEFAULT 1,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [Agent_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [Agent_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [Agent_providerAgentId_key] UNIQUE NONCLUSTERED ([providerAgentId])
);

-- CreateTable
CREATE TABLE [dbo].[CalAiPhoneNumber] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT,
    [teamId] INT,
    [phoneNumber] NVARCHAR(1000) NOT NULL,
    [provider] NVARCHAR(max) NOT NULL,
    [providerPhoneNumberId] NVARCHAR(1000),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [CalAiPhoneNumber_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [stripeCustomerId] NVARCHAR(max),
    [stripeSubscriptionId] NVARCHAR(1000),
    [subscriptionStatus] NVARCHAR(100),
    [inboundAgentId] NVARCHAR(1000),
    [outboundAgentId] NVARCHAR(1000),
    CONSTRAINT [CalAiPhoneNumber_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [CalAiPhoneNumber_phoneNumber_key] UNIQUE NONCLUSTERED ([phoneNumber])
);

CREATE UNIQUE NONCLUSTERED INDEX [CalAiPhoneNumber_providerPhoneNumberId_key] ON [dbo].[CalAiPhoneNumber]([providerPhoneNumberId]) WHERE [providerPhoneNumberId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [CalAiPhoneNumber_stripeSubscriptionId_key] ON [dbo].[CalAiPhoneNumber]([stripeSubscriptionId]) WHERE [stripeSubscriptionId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[TeamBilling] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT NOT NULL,
    [subscriptionId] NVARCHAR(1000) NOT NULL,
    [subscriptionItemId] NVARCHAR(max) NOT NULL,
    [customerId] NVARCHAR(max) NOT NULL,
    [status] NVARCHAR(max) NOT NULL,
    [planName] NVARCHAR(max) NOT NULL,
    [subscriptionStart] DATETIME2,
    [subscriptionTrialEnd] DATETIME2,
    [subscriptionEnd] DATETIME2,
    [billingPeriod] NVARCHAR(100),
    [billingMode] NVARCHAR(100) NOT NULL CONSTRAINT [TeamBilling_billingMode_df] DEFAULT 'SEATS',
    [pricePerSeat] INT,
    [paidSeats] INT,
    [highWaterMark] INT,
    [highWaterMarkPeriodStart] DATETIME2,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [TeamBilling_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [TeamBilling_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [TeamBilling_teamId_key] UNIQUE NONCLUSTERED ([teamId]),
    CONSTRAINT [TeamBilling_subscriptionId_key] UNIQUE NONCLUSTERED ([subscriptionId])
);

-- CreateTable
CREATE TABLE [dbo].[OrganizationBilling] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT NOT NULL,
    [subscriptionId] NVARCHAR(1000) NOT NULL,
    [subscriptionItemId] NVARCHAR(max) NOT NULL,
    [customerId] NVARCHAR(max) NOT NULL,
    [status] NVARCHAR(max) NOT NULL,
    [planName] NVARCHAR(max) NOT NULL,
    [subscriptionStart] DATETIME2,
    [subscriptionTrialEnd] DATETIME2,
    [subscriptionEnd] DATETIME2,
    [billingPeriod] NVARCHAR(100),
    [billingMode] NVARCHAR(100) NOT NULL CONSTRAINT [OrganizationBilling_billingMode_df] DEFAULT 'SEATS',
    [pricePerSeat] INT,
    [paidSeats] INT,
    [highWaterMark] INT,
    [highWaterMarkPeriodStart] DATETIME2,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [OrganizationBilling_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [OrganizationBilling_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [OrganizationBilling_teamId_key] UNIQUE NONCLUSTERED ([teamId]),
    CONSTRAINT [OrganizationBilling_subscriptionId_key] UNIQUE NONCLUSTERED ([subscriptionId])
);

-- CreateTable
CREATE TABLE [dbo].[SeatChangeLog] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT NOT NULL,
    [changeType] NVARCHAR(100) NOT NULL,
    [seatCount] INT NOT NULL,
    [userId] INT,
    [triggeredBy] INT,
    [changeDate] DATETIME2 NOT NULL CONSTRAINT [SeatChangeLog_changeDate_df] DEFAULT CURRENT_TIMESTAMP,
    [monthKey] NVARCHAR(1000) NOT NULL,
    [operationId] NVARCHAR(1000),
    [processedInProrationId] NVARCHAR(1000),
    [metadata] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [SeatChangeLog_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [teamBillingId] NVARCHAR(1000),
    [organizationBillingId] NVARCHAR(1000),
    CONSTRAINT [SeatChangeLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [SeatChangeLog_teamId_operationId_key] ON [dbo].[SeatChangeLog]([teamId],[operationId]) WHERE [operationId] IS NOT NULL;

-- CreateTable
CREATE TABLE [dbo].[MonthlyProration] (
    [id] NVARCHAR(1000) NOT NULL,
    [teamId] INT NOT NULL,
    [monthKey] NVARCHAR(1000) NOT NULL,
    [periodStart] DATETIME2 NOT NULL,
    [periodEnd] DATETIME2 NOT NULL,
    [seatsAtStart] INT NOT NULL,
    [seatsAdded] INT NOT NULL,
    [seatsRemoved] INT NOT NULL,
    [netSeatIncrease] INT NOT NULL,
    [seatsAtEnd] INT NOT NULL,
    [subscriptionId] NVARCHAR(max) NOT NULL,
    [subscriptionItemId] NVARCHAR(max) NOT NULL,
    [customerId] NVARCHAR(max) NOT NULL,
    [subscriptionStart] DATETIME2 NOT NULL,
    [subscriptionEnd] DATETIME2 NOT NULL,
    [remainingDays] INT NOT NULL,
    [pricePerSeat] INT NOT NULL,
    [proratedAmount] INT NOT NULL,
    [invoiceItemId] NVARCHAR(max),
    [invoiceId] NVARCHAR(max),
    [invoiceUrl] NVARCHAR(max),
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [MonthlyProration_status_df] DEFAULT 'PENDING',
    [chargedAt] DATETIME2,
    [failedAt] DATETIME2,
    [failureReason] NVARCHAR(max),
    [retryCount] INT NOT NULL CONSTRAINT [MonthlyProration_retryCount_df] DEFAULT 0,
    [metadata] NVARCHAR(max),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [MonthlyProration_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [teamBillingId] NVARCHAR(1000),
    [organizationBillingId] NVARCHAR(1000),
    CONSTRAINT [MonthlyProration_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [MonthlyProration_teamId_monthKey_key] UNIQUE NONCLUSTERED ([teamId],[monthKey])
);

-- CreateTable
CREATE TABLE [dbo].[CalendarCacheEvent] (
    [id] NVARCHAR(1000) NOT NULL,
    [selectedCalendarId] NVARCHAR(1000) NOT NULL,
    [externalId] NVARCHAR(1000) NOT NULL,
    [externalEtag] NVARCHAR(max) NOT NULL,
    [iCalUID] NVARCHAR(1000),
    [iCalSequence] INT NOT NULL CONSTRAINT [CalendarCacheEvent_iCalSequence_df] DEFAULT 0,
    [summary] NVARCHAR(max),
    [description] NVARCHAR(max),
    [location] NVARCHAR(max),
    [start] DATETIME2 NOT NULL,
    [end] DATETIME2 NOT NULL,
    [isAllDay] BIT NOT NULL CONSTRAINT [CalendarCacheEvent_isAllDay_df] DEFAULT 0,
    [timeZone] NVARCHAR(max),
    [status] NVARCHAR(100) NOT NULL CONSTRAINT [CalendarCacheEvent_status_df] DEFAULT 'confirmed',
    [recurringEventId] NVARCHAR(max),
    [originalStartTime] DATETIME2,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [CalendarCacheEvent_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    [externalCreatedAt] DATETIME2,
    [externalUpdatedAt] DATETIME2,
    CONSTRAINT [CalendarCacheEvent_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [CalendarCacheEvent_selectedCalendarId_externalId_key] UNIQUE NONCLUSTERED ([selectedCalendarId],[externalId])
);

-- CreateTable
CREATE TABLE [dbo].[IntegrationAttributeSync] (
    [id] NVARCHAR(1000) NOT NULL,
    [organizationId] INT NOT NULL,
    [name] NVARCHAR(max) NOT NULL,
    [integration] NVARCHAR(max) NOT NULL,
    [credentialId] INT,
    [enabled] BIT NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [IntegrationAttributeSync_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [IntegrationAttributeSync_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[AttributeSyncRule] (
    [id] NVARCHAR(1000) NOT NULL,
    [integrationAttributeSyncId] NVARCHAR(1000) NOT NULL,
    [rule] NVARCHAR(max) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AttributeSyncRule_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [AttributeSyncRule_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [AttributeSyncRule_integrationAttributeSyncId_key] UNIQUE NONCLUSTERED ([integrationAttributeSyncId])
);

-- CreateTable
CREATE TABLE [dbo].[AttributeSyncFieldMapping] (
    [id] NVARCHAR(1000) NOT NULL,
    [integrationFieldName] NVARCHAR(max) NOT NULL,
    [attributeId] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL,
    [integrationAttributeSyncId] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AttributeSyncFieldMapping_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [AttributeSyncFieldMapping_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [AttributeSyncFieldMapping_integrationAttributeSyncId_attributeId_key] UNIQUE NONCLUSTERED ([integrationAttributeSyncId],[attributeId])
);

-- CreateTable
CREATE TABLE [dbo].[_user_eventtype] (
    [A] INT NOT NULL,
    [B] INT NOT NULL,
    CONSTRAINT [_user_eventtype_AB_unique] UNIQUE NONCLUSTERED ([A],[B])
);

-- CreateTable
CREATE TABLE [dbo].[_PlatformOAuthClientToUser] (
    [A] NVARCHAR(1000) NOT NULL,
    [B] INT NOT NULL,
    CONSTRAINT [_PlatformOAuthClientToUser_AB_unique] UNIQUE NONCLUSTERED ([A],[B])
);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Host_memberId_idx] ON [dbo].[Host]([memberId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Host_userId_idx] ON [dbo].[Host]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Host_eventTypeId_idx] ON [dbo].[Host]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Host_scheduleId_idx] ON [dbo].[Host]([scheduleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HostGroup_name_idx] ON [dbo].[HostGroup]([name]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HostGroup_eventTypeId_idx] ON [dbo].[HostGroup]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HostLocation_credentialId_idx] ON [dbo].[HostLocation]([credentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HostLocation_eventTypeId_idx] ON [dbo].[HostLocation]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VideoCallGuest_bookingUid_idx] ON [dbo].[VideoCallGuest]([bookingUid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VideoCallGuest_email_idx] ON [dbo].[VideoCallGuest]([email]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_userId_idx] ON [dbo].[EventType]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_teamId_idx] ON [dbo].[EventType]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_profileId_idx] ON [dbo].[EventType]([profileId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_scheduleId_idx] ON [dbo].[EventType]([scheduleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_secondaryEmailId_idx] ON [dbo].[EventType]([secondaryEmailId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_parentId_idx] ON [dbo].[EventType]([parentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_parentId_teamId_idx] ON [dbo].[EventType]([parentId], [teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventType_restrictionScheduleId_idx] ON [dbo].[EventType]([restrictionScheduleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Credential_appId_idx] ON [dbo].[Credential]([appId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Credential_subscriptionId_idx] ON [dbo].[Credential]([subscriptionId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Credential_invalid_idx] ON [dbo].[Credential]([invalid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Credential_userId_delegationCredentialId_idx] ON [dbo].[Credential]([userId], [delegationCredentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Credential_teamId_idx] ON [dbo].[Credential]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [DestinationCalendar_userId_idx] ON [dbo].[DestinationCalendar]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [DestinationCalendar_eventTypeId_idx] ON [dbo].[DestinationCalendar]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [DestinationCalendar_credentialId_idx] ON [dbo].[DestinationCalendar]([credentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [TravelSchedule_startDate_idx] ON [dbo].[TravelSchedule]([startDate]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [TravelSchedule_endDate_idx] ON [dbo].[TravelSchedule]([endDate]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [users_username_idx] ON [dbo].[users]([username]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [users_emailVerified_idx] ON [dbo].[users]([emailVerified]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [users_identityProvider_idx] ON [dbo].[users]([identityProvider]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [users_identityProviderId_idx] ON [dbo].[users]([identityProviderId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [NotificationsSubscriptions_userId_subscription_idx] ON [dbo].[NotificationsSubscriptions]([userId], [subscription]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Profile_uid_idx] ON [dbo].[Profile]([uid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Profile_userId_idx] ON [dbo].[Profile]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Profile_organizationId_idx] ON [dbo].[Profile]([organizationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Team_parentId_idx] ON [dbo].[Team]([parentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Membership_teamId_idx] ON [dbo].[Membership]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Membership_userId_idx] ON [dbo].[Membership]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Membership_accepted_idx] ON [dbo].[Membership]([accepted]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Membership_role_idx] ON [dbo].[Membership]([role]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Membership_customRoleId_idx] ON [dbo].[Membership]([customRoleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerificationToken_token_idx] ON [dbo].[VerificationToken]([token]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerificationToken_teamId_idx] ON [dbo].[VerificationToken]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerificationToken_secondaryEmailId_idx] ON [dbo].[VerificationToken]([secondaryEmailId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [InstantMeetingToken_token_idx] ON [dbo].[InstantMeetingToken]([token]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReference_bookingId_idx] ON [dbo].[BookingReference]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReference_type_idx] ON [dbo].[BookingReference]([type]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReference_uid_idx] ON [dbo].[BookingReference]([uid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Attendee_email_idx] ON [dbo].[Attendee]([email]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Attendee_bookingId_idx] ON [dbo].[Attendee]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Attendee_email_bookingId_idx] ON [dbo].[Attendee]([email], [bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_eventTypeId_idx] ON [dbo].[Booking]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_userId_idx] ON [dbo].[Booking]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_destinationCalendarId_idx] ON [dbo].[Booking]([destinationCalendarId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_recurringEventId_idx] ON [dbo].[Booking]([recurringEventId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_uid_idx] ON [dbo].[Booking]([uid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_status_idx] ON [dbo].[Booking]([status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_startTime_endTime_status_idx] ON [dbo].[Booking]([startTime], [endTime], [status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_fromReschedule_idx] ON [dbo].[Booking]([fromReschedule]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_userId_endTime_idx] ON [dbo].[Booking]([userId], [endTime]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_userId_status_startTime_idx] ON [dbo].[Booking]([userId], [status], [startTime]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_eventTypeId_status_idx] ON [dbo].[Booking]([eventTypeId], [status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Booking_userId_createdAt_idx] ON [dbo].[Booking]([userId], [createdAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Schedule_userId_idx] ON [dbo].[Schedule]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Availability_userId_idx] ON [dbo].[Availability]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Availability_eventTypeId_idx] ON [dbo].[Availability]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Availability_scheduleId_idx] ON [dbo].[Availability]([scheduleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_userId_idx] ON [dbo].[SelectedCalendar]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_externalId_idx] ON [dbo].[SelectedCalendar]([externalId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_eventTypeId_idx] ON [dbo].[SelectedCalendar]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_credentialId_idx] ON [dbo].[SelectedCalendar]([credentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_channelId_idx] ON [dbo].[SelectedCalendar]([channelId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_watch_idx] ON [dbo].[SelectedCalendar]([integration], [googleChannelExpiration], [error], [watchAttempts], [maxAttempts]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SelectedCalendar_unwatch_idx] ON [dbo].[SelectedCalendar]([integration], [googleChannelExpiration], [error], [unwatchAttempts], [maxAttempts]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventTypeCustomInput_eventTypeId_idx] ON [dbo].[EventTypeCustomInput]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [ReminderMail_referenceId_idx] ON [dbo].[ReminderMail]([referenceId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [ReminderMail_reminderType_idx] ON [dbo].[ReminderMail]([reminderType]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Payment_bookingId_idx] ON [dbo].[Payment]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Payment_externalId_idx] ON [dbo].[Payment]([externalId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Webhook_active_idx] ON [dbo].[Webhook]([active]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [ApiKey_userId_idx] ON [dbo].[ApiKey]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [RateLimit_apiKeyId_idx] ON [dbo].[RateLimit]([apiKeyId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HashedLink_eventTypeId_idx] ON [dbo].[HashedLink]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Account_userId_idx] ON [dbo].[Account]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Account_type_idx] ON [dbo].[Account]([type]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Session_userId_idx] ON [dbo].[Session]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [App_enabled_idx] ON [dbo].[App]([enabled]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Feedback_userId_idx] ON [dbo].[Feedback]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Feedback_rating_idx] ON [dbo].[Feedback]([rating]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingSeat_bookingId_idx] ON [dbo].[BookingSeat]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingSeat_attendeeId_idx] ON [dbo].[BookingSeat]([attendeeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerifiedNumber_userId_idx] ON [dbo].[VerifiedNumber]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerifiedNumber_teamId_idx] ON [dbo].[VerifiedNumber]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerifiedEmail_userId_idx] ON [dbo].[VerifiedEmail]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [VerifiedEmail_teamId_idx] ON [dbo].[VerifiedEmail]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Feature_enabled_idx] ON [dbo].[Feature]([enabled]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Feature_stale_idx] ON [dbo].[Feature]([stale]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [UserFeatures_userId_featureId_idx] ON [dbo].[UserFeatures]([userId], [featureId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [TeamFeatures_teamId_featureId_idx] ON [dbo].[TeamFeatures]([teamId], [featureId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OAuthClient_userId_idx] ON [dbo].[OAuthClient]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_userId_idx] ON [dbo].[BookingDenormalized]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_createdAt_idx] ON [dbo].[BookingDenormalized]([createdAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_eventTypeId_idx] ON [dbo].[BookingDenormalized]([eventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_eventParentId_idx] ON [dbo].[BookingDenormalized]([eventParentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_teamId_idx] ON [dbo].[BookingDenormalized]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_startTime_idx] ON [dbo].[BookingDenormalized]([startTime]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_endTime_idx] ON [dbo].[BookingDenormalized]([endTime]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_status_idx] ON [dbo].[BookingDenormalized]([status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_teamId_isTeamBooking_idx] ON [dbo].[BookingDenormalized]([teamId], [isTeamBooking]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_userId_isTeamBooking_idx] ON [dbo].[BookingDenormalized]([userId], [isTeamBooking]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingDenormalized_startTime_endTime_idx] ON [dbo].[BookingDenormalized]([startTime], [endTime]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalendarCache_userId_key_idx] ON [dbo].[CalendarCache]([userId], [key]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OutOfOfficeEntry_uuid_idx] ON [dbo].[OutOfOfficeEntry]([uuid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OutOfOfficeEntry_userId_idx] ON [dbo].[OutOfOfficeEntry]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OutOfOfficeEntry_toUserId_idx] ON [dbo].[OutOfOfficeEntry]([toUserId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OutOfOfficeEntry_start_end_idx] ON [dbo].[OutOfOfficeEntry]([start], [end]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HolidayCache_countryCode_year_idx] ON [dbo].[HolidayCache]([countryCode], [year]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [HolidayCache_countryCode_date_idx] ON [dbo].[HolidayCache]([countryCode], [date]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SecondaryEmail_userId_idx] ON [dbo].[SecondaryEmail]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SecondaryEmail_email_emailVerified_idx] ON [dbo].[SecondaryEmail]([email], [emailVerified]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Task_succeededAt_idx] ON [dbo].[Task]([succeededAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Task_scheduledAt_succeededAt_idx] ON [dbo].[Task]([scheduledAt], [succeededAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [ManagedOrganization_managerOrganizationId_idx] ON [dbo].[ManagedOrganization]([managerOrganizationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Attribute_teamId_idx] ON [dbo].[Attribute]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AssignmentReason_bookingId_idx] ON [dbo].[AssignmentReason]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [DelegationCredential_enabled_idx] ON [dbo].[DelegationCredential]([enabled]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [EventTypeTranslation_eventTypeId_field_targetLocale_idx] ON [dbo].[EventTypeTranslation]([eventTypeId], [field], [targetLocale]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Watchlist_isGlobal_action_organizationId_type_value_idx] ON [dbo].[Watchlist]([isGlobal], [action], [organizationId], [type], [value]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WatchlistAudit_watchlistId_changedAt_idx] ON [dbo].[WatchlistAudit]([watchlistId], [changedAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_bookerEmail_idx] ON [dbo].[BookingReport]([bookerEmail]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_reportedById_idx] ON [dbo].[BookingReport]([reportedById]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_organizationId_idx] ON [dbo].[BookingReport]([organizationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_watchlistId_idx] ON [dbo].[BookingReport]([watchlistId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_globalWatchlistId_idx] ON [dbo].[BookingReport]([globalWatchlistId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_systemStatus_idx] ON [dbo].[BookingReport]([systemStatus]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingReport_createdAt_idx] ON [dbo].[BookingReport]([createdAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_reportedById_idx] ON [dbo].[WrongAssignmentReport]([reportedById]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_teamId_idx] ON [dbo].[WrongAssignmentReport]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_status_idx] ON [dbo].[WrongAssignmentReport]([status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_reviewedById_idx] ON [dbo].[WrongAssignmentReport]([reviewedById]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_createdAt_idx] ON [dbo].[WrongAssignmentReport]([createdAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [WrongAssignmentReport_teamId_status_createdAt_idx] ON [dbo].[WrongAssignmentReport]([teamId], [status], [createdAt]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OrganizationOnboarding_orgOwnerEmail_idx] ON [dbo].[OrganizationOnboarding]([orgOwnerEmail]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [OrganizationOnboarding_stripeCustomerId_idx] ON [dbo].[OrganizationOnboarding]([stripeCustomerId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [InternalNotePreset_teamId_idx] ON [dbo].[InternalNotePreset]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [FilterSegment_scope_userId_tableIdentifier_idx] ON [dbo].[FilterSegment]([scope], [userId], [tableIdentifier]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [FilterSegment_scope_teamId_tableIdentifier_idx] ON [dbo].[FilterSegment]([scope], [teamId], [tableIdentifier]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [UserFilterSegmentPreference_userId_idx] ON [dbo].[UserFilterSegmentPreference]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [UserFilterSegmentPreference_segmentId_idx] ON [dbo].[UserFilterSegmentPreference]([segmentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingInternalNote_bookingId_idx] ON [dbo].[BookingInternalNote]([bookingId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Role_teamId_idx] ON [dbo].[Role]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [RolePermission_roleId_idx] ON [dbo].[RolePermission]([roleId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [RolePermission_action_idx] ON [dbo].[RolePermission]([action]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AuditActor_email_idx] ON [dbo].[AuditActor]([email]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AuditActor_userUuid_idx] ON [dbo].[AuditActor]([userUuid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AuditActor_attendeeId_idx] ON [dbo].[AuditActor]([attendeeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AuditActor_credentialId_idx] ON [dbo].[AuditActor]([credentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingAudit_actorId_idx] ON [dbo].[BookingAudit]([actorId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingAudit_bookingUid_idx] ON [dbo].[BookingAudit]([bookingUid]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingAudit_timestamp_idx] ON [dbo].[BookingAudit]([timestamp]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [BookingAudit_operationId_idx] ON [dbo].[BookingAudit]([operationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Agent_userId_idx] ON [dbo].[Agent]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Agent_teamId_idx] ON [dbo].[Agent]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Agent_inboundEventTypeId_idx] ON [dbo].[Agent]([inboundEventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [Agent_outboundEventTypeId_idx] ON [dbo].[Agent]([outboundEventTypeId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalAiPhoneNumber_userId_idx] ON [dbo].[CalAiPhoneNumber]([userId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalAiPhoneNumber_teamId_idx] ON [dbo].[CalAiPhoneNumber]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalAiPhoneNumber_inboundAgentId_idx] ON [dbo].[CalAiPhoneNumber]([inboundAgentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalAiPhoneNumber_outboundAgentId_idx] ON [dbo].[CalAiPhoneNumber]([outboundAgentId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SeatChangeLog_teamId_monthKey_idx] ON [dbo].[SeatChangeLog]([teamId], [monthKey]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SeatChangeLog_teamId_processedInProrationId_idx] ON [dbo].[SeatChangeLog]([teamId], [processedInProrationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [SeatChangeLog_monthKey_idx] ON [dbo].[SeatChangeLog]([monthKey]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [MonthlyProration_monthKey_status_idx] ON [dbo].[MonthlyProration]([monthKey], [status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [MonthlyProration_status_idx] ON [dbo].[MonthlyProration]([status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [MonthlyProration_teamId_idx] ON [dbo].[MonthlyProration]([teamId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalendarCacheEvent_start_end_status_idx] ON [dbo].[CalendarCacheEvent]([start], [end], [status]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [CalendarCacheEvent_selectedCalendarId_iCalUID_idx] ON [dbo].[CalendarCacheEvent]([selectedCalendarId], [iCalUID]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [IntegrationAttributeSync_organizationId_idx] ON [dbo].[IntegrationAttributeSync]([organizationId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [IntegrationAttributeSync_credentialId_idx] ON [dbo].[IntegrationAttributeSync]([credentialId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [AttributeSyncFieldMapping_integrationAttributeSyncId_idx] ON [dbo].[AttributeSyncFieldMapping]([integrationAttributeSyncId]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [_user_eventtype_B_index] ON [dbo].[_user_eventtype]([B]);

-- CreateIndex
CREATE NONCLUSTERED INDEX [_PlatformOAuthClientToUser_B_index] ON [dbo].[_PlatformOAuthClientToUser]([B]);

-- AddForeignKey
ALTER TABLE [dbo].[Host] ADD CONSTRAINT [Host_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Host] ADD CONSTRAINT [Host_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Host] ADD CONSTRAINT [Host_memberId_fkey] FOREIGN KEY ([memberId]) REFERENCES [dbo].[Membership]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[HostGroup] ADD CONSTRAINT [HostGroup_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[HostLocation] ADD CONSTRAINT [HostLocation_userId_eventTypeId_fkey] FOREIGN KEY ([userId], [eventTypeId]) REFERENCES [dbo].[Host]([userId],[eventTypeId]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[CalVideoSettings] ADD CONSTRAINT [CalVideoSettings_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[EventType] ADD CONSTRAINT [EventType_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[EventType] ADD CONSTRAINT [EventType_secondaryEmailId_fkey] FOREIGN KEY ([secondaryEmailId]) REFERENCES [dbo].[SecondaryEmail]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Credential] ADD CONSTRAINT [Credential_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Credential] ADD CONSTRAINT [Credential_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Credential] ADD CONSTRAINT [Credential_appId_fkey] FOREIGN KEY ([appId]) REFERENCES [dbo].[App]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Credential] ADD CONSTRAINT [Credential_delegationCredentialId_fkey] FOREIGN KEY ([delegationCredentialId]) REFERENCES [dbo].[DelegationCredential]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[DestinationCalendar] ADD CONSTRAINT [DestinationCalendar_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[DestinationCalendar] ADD CONSTRAINT [DestinationCalendar_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[DestinationCalendar] ADD CONSTRAINT [DestinationCalendar_delegationCredentialId_fkey] FOREIGN KEY ([delegationCredentialId]) REFERENCES [dbo].[DelegationCredential]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[UserPassword] ADD CONSTRAINT [UserPassword_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[TravelSchedule] ADD CONSTRAINT [TravelSchedule_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[NotificationsSubscriptions] ADD CONSTRAINT [NotificationsSubscriptions_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT [Profile_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT [Profile_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Team] ADD CONSTRAINT [Team_createdByOAuthClientId_fkey] FOREIGN KEY ([createdByOAuthClientId]) REFERENCES [dbo].[PlatformOAuthClient]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CreditBalance] ADD CONSTRAINT [CreditBalance_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CreditBalance] ADD CONSTRAINT [CreditBalance_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CreditPurchaseLog] ADD CONSTRAINT [CreditPurchaseLog_creditBalanceId_fkey] FOREIGN KEY ([creditBalanceId]) REFERENCES [dbo].[CreditBalance]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CreditExpenseLog] ADD CONSTRAINT [CreditExpenseLog_creditBalanceId_fkey] FOREIGN KEY ([creditBalanceId]) REFERENCES [dbo].[CreditBalance]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CreditExpenseLog] ADD CONSTRAINT [CreditExpenseLog_bookingUid_fkey] FOREIGN KEY ([bookingUid]) REFERENCES [dbo].[Booking]([uid]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[OrganizationSettings] ADD CONSTRAINT [OrganizationSettings_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[VerificationToken] ADD CONSTRAINT [VerificationToken_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[VerificationToken] ADD CONSTRAINT [VerificationToken_secondaryEmailId_fkey] FOREIGN KEY ([secondaryEmailId]) REFERENCES [dbo].[SecondaryEmail]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[InstantMeetingToken] ADD CONSTRAINT [InstantMeetingToken_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[InstantMeetingToken] ADD CONSTRAINT [InstantMeetingToken_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReference] ADD CONSTRAINT [BookingReference_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReference] ADD CONSTRAINT [BookingReference_credentialId_fkey] FOREIGN KEY ([credentialId]) REFERENCES [dbo].[Credential]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Attendee] ADD CONSTRAINT [Attendee_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Tracking] ADD CONSTRAINT [Tracking_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Schedule] ADD CONSTRAINT [Schedule_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Availability] ADD CONSTRAINT [Availability_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Availability] ADD CONSTRAINT [Availability_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[SelectedCalendar] ADD CONSTRAINT [SelectedCalendar_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[SelectedCalendar] ADD CONSTRAINT [SelectedCalendar_delegationCredentialId_fkey] FOREIGN KEY ([delegationCredentialId]) REFERENCES [dbo].[DelegationCredential]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[SelectedCalendar] ADD CONSTRAINT [SelectedCalendar_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[EventTypeCustomInput] ADD CONSTRAINT [EventTypeCustomInput_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [Payment_appId_fkey] FOREIGN KEY ([appId]) REFERENCES [dbo].[App]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [Payment_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Webhook] ADD CONSTRAINT [Webhook_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Webhook] ADD CONSTRAINT [Webhook_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[Webhook] ADD CONSTRAINT [Webhook_appId_fkey] FOREIGN KEY ([appId]) REFERENCES [dbo].[App]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[ApiKey] ADD CONSTRAINT [ApiKey_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[ApiKey] ADD CONSTRAINT [ApiKey_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[ApiKey] ADD CONSTRAINT [ApiKey_appId_fkey] FOREIGN KEY ([appId]) REFERENCES [dbo].[App]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[RateLimit] ADD CONSTRAINT [RateLimit_apiKeyId_fkey] FOREIGN KEY ([apiKeyId]) REFERENCES [dbo].[ApiKey]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[HashedLink] ADD CONSTRAINT [HashedLink_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Account] ADD CONSTRAINT [Account_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Session] ADD CONSTRAINT [Session_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Feedback] ADD CONSTRAINT [Feedback_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[WebhookScheduledTriggers] ADD CONSTRAINT [WebhookScheduledTriggers_webhookId_fkey] FOREIGN KEY ([webhookId]) REFERENCES [dbo].[Webhook]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[WebhookScheduledTriggers] ADD CONSTRAINT [WebhookScheduledTriggers_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingSeat] ADD CONSTRAINT [BookingSeat_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[VerifiedNumber] ADD CONSTRAINT [VerifiedNumber_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[VerifiedNumber] ADD CONSTRAINT [VerifiedNumber_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[VerifiedEmail] ADD CONSTRAINT [VerifiedEmail_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[VerifiedEmail] ADD CONSTRAINT [VerifiedEmail_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[UserFeatures] ADD CONSTRAINT [UserFeatures_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[UserFeatures] ADD CONSTRAINT [UserFeatures_featureId_fkey] FOREIGN KEY ([featureId]) REFERENCES [dbo].[Feature]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[TeamFeatures] ADD CONSTRAINT [TeamFeatures_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[TeamFeatures] ADD CONSTRAINT [TeamFeatures_featureId_fkey] FOREIGN KEY ([featureId]) REFERENCES [dbo].[Feature]([slug]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[AccessCode] ADD CONSTRAINT [AccessCode_clientId_fkey] FOREIGN KEY ([clientId]) REFERENCES [dbo].[OAuthClient]([clientId]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AccessCode] ADD CONSTRAINT [AccessCode_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AccessCode] ADD CONSTRAINT [AccessCode_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CalendarCache] ADD CONSTRAINT [CalendarCache_credentialId_fkey] FOREIGN KEY ([credentialId]) REFERENCES [dbo].[Credential]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[OutOfOfficeEntry] ADD CONSTRAINT [OutOfOfficeEntry_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[OutOfOfficeReason] ADD CONSTRAINT [OutOfOfficeReason_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[UserHolidaySettings] ADD CONSTRAINT [UserHolidaySettings_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[PlatformAuthorizationToken] ADD CONSTRAINT [PlatformAuthorizationToken_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[PlatformAuthorizationToken] ADD CONSTRAINT [PlatformAuthorizationToken_platformOAuthClientId_fkey] FOREIGN KEY ([platformOAuthClientId]) REFERENCES [dbo].[PlatformOAuthClient]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AccessToken] ADD CONSTRAINT [AccessToken_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AccessToken] ADD CONSTRAINT [AccessToken_platformOAuthClientId_fkey] FOREIGN KEY ([platformOAuthClientId]) REFERENCES [dbo].[PlatformOAuthClient]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[RefreshToken] ADD CONSTRAINT [RefreshToken_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[RefreshToken] ADD CONSTRAINT [RefreshToken_platformOAuthClientId_fkey] FOREIGN KEY ([platformOAuthClientId]) REFERENCES [dbo].[PlatformOAuthClient]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[DSyncData] ADD CONSTRAINT [DSyncData_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[OrganizationSettings]([organizationId]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[DSyncTeamGroupMapping] ADD CONSTRAINT [DSyncTeamGroupMapping_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[ManagedOrganization] ADD CONSTRAINT [ManagedOrganization_managedOrganizationId_fkey] FOREIGN KEY ([managedOrganizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[PlatformBilling] ADD CONSTRAINT [PlatformBilling_id_fkey] FOREIGN KEY ([id]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AttributeOption] ADD CONSTRAINT [AttributeOption_attributeId_fkey] FOREIGN KEY ([attributeId]) REFERENCES [dbo].[Attribute]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Attribute] ADD CONSTRAINT [Attribute_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AttributeToUser] ADD CONSTRAINT [AttributeToUser_memberId_fkey] FOREIGN KEY ([memberId]) REFERENCES [dbo].[Membership]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AttributeToUser] ADD CONSTRAINT [AttributeToUser_attributeOptionId_fkey] FOREIGN KEY ([attributeOptionId]) REFERENCES [dbo].[AttributeOption]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AttributeToUser] ADD CONSTRAINT [AttributeToUser_createdById_fkey] FOREIGN KEY ([createdById]) REFERENCES [dbo].[users]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[AssignmentReason] ADD CONSTRAINT [AssignmentReason_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[DelegationCredential] ADD CONSTRAINT [DelegationCredential_workspacePlatformId_fkey] FOREIGN KEY ([workspacePlatformId]) REFERENCES [dbo].[WorkspacePlatform]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[EventTypeTranslation] ADD CONSTRAINT [EventTypeTranslation_eventTypeId_fkey] FOREIGN KEY ([eventTypeId]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[EventTypeTranslation] ADD CONSTRAINT [EventTypeTranslation_createdBy_fkey] FOREIGN KEY ([createdBy]) REFERENCES [dbo].[users]([id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[EventTypeTranslation] ADD CONSTRAINT [EventTypeTranslation_updatedBy_fkey] FOREIGN KEY ([updatedBy]) REFERENCES [dbo].[users]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[WatchlistAudit] ADD CONSTRAINT [WatchlistAudit_watchlistId_fkey] FOREIGN KEY ([watchlistId]) REFERENCES [dbo].[Watchlist]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReport] ADD CONSTRAINT [BookingReport_bookingUid_fkey] FOREIGN KEY ([bookingUid]) REFERENCES [dbo].[Booking]([uid]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReport] ADD CONSTRAINT [BookingReport_reportedById_fkey] FOREIGN KEY ([reportedById]) REFERENCES [dbo].[users]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReport] ADD CONSTRAINT [BookingReport_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingReport] ADD CONSTRAINT [BookingReport_watchlistId_fkey] FOREIGN KEY ([watchlistId]) REFERENCES [dbo].[Watchlist]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[WrongAssignmentReport] ADD CONSTRAINT [WrongAssignmentReport_bookingUid_fkey] FOREIGN KEY ([bookingUid]) REFERENCES [dbo].[Booking]([uid]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[WrongAssignmentReport] ADD CONSTRAINT [WrongAssignmentReport_reportedById_fkey] FOREIGN KEY ([reportedById]) REFERENCES [dbo].[users]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[WrongAssignmentReport] ADD CONSTRAINT [WrongAssignmentReport_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[OrganizationOnboarding] ADD CONSTRAINT [OrganizationOnboarding_createdById_fkey] FOREIGN KEY ([createdById]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[OrganizationOnboarding] ADD CONSTRAINT [OrganizationOnboarding_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[InternalNotePreset] ADD CONSTRAINT [InternalNotePreset_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[FilterSegment] ADD CONSTRAINT [FilterSegment_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[FilterSegment] ADD CONSTRAINT [FilterSegment_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[UserFilterSegmentPreference] ADD CONSTRAINT [UserFilterSegmentPreference_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[BookingInternalNote] ADD CONSTRAINT [BookingInternalNote_notePresetId_fkey] FOREIGN KEY ([notePresetId]) REFERENCES [dbo].[InternalNotePreset]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingInternalNote] ADD CONSTRAINT [BookingInternalNote_bookingId_fkey] FOREIGN KEY ([bookingId]) REFERENCES [dbo].[Booking]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingInternalNote] ADD CONSTRAINT [BookingInternalNote_createdById_fkey] FOREIGN KEY ([createdById]) REFERENCES [dbo].[users]([id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Role] ADD CONSTRAINT [Role_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[RolePermission] ADD CONSTRAINT [RolePermission_roleId_fkey] FOREIGN KEY ([roleId]) REFERENCES [dbo].[Role]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[BookingAudit] ADD CONSTRAINT [BookingAudit_actorId_fkey] FOREIGN KEY ([actorId]) REFERENCES [dbo].[AuditActor]([id]) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Agent] ADD CONSTRAINT [Agent_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[Agent] ADD CONSTRAINT [Agent_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CalAiPhoneNumber] ADD CONSTRAINT [CalAiPhoneNumber_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[CalAiPhoneNumber] ADD CONSTRAINT [CalAiPhoneNumber_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[TeamBilling] ADD CONSTRAINT [TeamBilling_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[OrganizationBilling] ADD CONSTRAINT [OrganizationBilling_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[SeatChangeLog] ADD CONSTRAINT [SeatChangeLog_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[MonthlyProration] ADD CONSTRAINT [MonthlyProration_teamId_fkey] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[CalendarCacheEvent] ADD CONSTRAINT [CalendarCacheEvent_selectedCalendarId_fkey] FOREIGN KEY ([selectedCalendarId]) REFERENCES [dbo].[SelectedCalendar]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[IntegrationAttributeSync] ADD CONSTRAINT [IntegrationAttributeSync_organizationId_fkey] FOREIGN KEY ([organizationId]) REFERENCES [dbo].[Team]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[AttributeSyncRule] ADD CONSTRAINT [AttributeSyncRule_integrationAttributeSyncId_fkey] FOREIGN KEY ([integrationAttributeSyncId]) REFERENCES [dbo].[IntegrationAttributeSync]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE [dbo].[AttributeSyncFieldMapping] ADD CONSTRAINT [AttributeSyncFieldMapping_attributeId_fkey] FOREIGN KEY ([attributeId]) REFERENCES [dbo].[Attribute]([id]) ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey

-- AddForeignKey
ALTER TABLE [dbo].[_user_eventtype] ADD CONSTRAINT [_user_eventtype_A_fkey] FOREIGN KEY ([A]) REFERENCES [dbo].[EventType]([id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[_user_eventtype] ADD CONSTRAINT [_user_eventtype_B_fkey] FOREIGN KEY ([B]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[_PlatformOAuthClientToUser] ADD CONSTRAINT [_PlatformOAuthClientToUser_A_fkey] FOREIGN KEY ([A]) REFERENCES [dbo].[PlatformOAuthClient]([id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[_PlatformOAuthClientToUser] ADD CONSTRAINT [_PlatformOAuthClientToUser_B_fkey] FOREIGN KEY ([B]) REFERENCES [dbo].[users]([id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- Emulated ON DELETE actions (sqlserver/emulated-relations.sql)
-- GENERATED by packages/prisma/sqlserver/generate-schema.mjs. Do not edit.
-- ON DELETE behaviour SQL Server can't hold as foreign keys (see emulatedRelations in fields.json).
-- new-migration.mjs adds this to a migration whenever it changes.
DECLARE @drop NVARCHAR(MAX) = N'';
SELECT @drop += N'DROP TRIGGER [dbo].' + QUOTENAME(name) + N';' FROM sys.triggers WHERE name LIKE N'%[_]emulated[_]on[_]delete';
EXEC sp_executesql @drop;
EXEC(N'CREATE TRIGGER [dbo].[Agent_emulated_on_delete] ON [dbo].[Agent] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[inboundAgentId] = NULL FROM [dbo].[CalAiPhoneNumber] c INNER JOIN deleted d ON c.[inboundAgentId] = d.[id]; -- CalAiPhoneNumber.inboundAgent
  UPDATE c SET c.[outboundAgentId] = NULL FROM [dbo].[CalAiPhoneNumber] c INNER JOIN deleted d ON c.[outboundAgentId] = d.[id]; -- CalAiPhoneNumber.outboundAgent
END');
EXEC(N'CREATE TRIGGER [dbo].[Attendee_emulated_on_delete] ON [dbo].[Attendee] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[BookingSeat] c INNER JOIN deleted d ON c.[attendeeId] = d.[id]; -- BookingSeat.attendee
END');
EXEC(N'CREATE TRIGGER [dbo].[Credential_emulated_on_delete] ON [dbo].[Credential] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[credentialId] = NULL FROM [dbo].[HostLocation] c INNER JOIN deleted d ON c.[credentialId] = d.[id]; -- HostLocation.credential
  DELETE c FROM [dbo].[DestinationCalendar] c INNER JOIN deleted d ON c.[credentialId] = d.[id]; -- DestinationCalendar.credential
  DELETE c FROM [dbo].[SelectedCalendar] c INNER JOIN deleted d ON c.[credentialId] = d.[id]; -- SelectedCalendar.credential
  DELETE c FROM [dbo].[IntegrationAttributeSync] c INNER JOIN deleted d ON c.[credentialId] = d.[id]; -- IntegrationAttributeSync.credential
END');
EXEC(N'CREATE TRIGGER [dbo].[DelegationCredential_emulated_on_delete] ON [dbo].[DelegationCredential] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[delegationCredentialId] = NULL FROM [dbo].[BookingReference] c INNER JOIN deleted d ON c.[delegationCredentialId] = d.[id]; -- BookingReference.delegationCredential
END');
EXEC(N'CREATE TRIGGER [dbo].[DestinationCalendar_emulated_on_delete] ON [dbo].[DestinationCalendar] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[destinationCalendarId] = NULL FROM [dbo].[Booking] c INNER JOIN deleted d ON c.[destinationCalendarId] = d.[id]; -- Booking.destinationCalendar
END');
EXEC(N'CREATE TRIGGER [dbo].[DSyncData_emulated_on_delete] ON [dbo].[DSyncData] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[DSyncTeamGroupMapping] c INNER JOIN deleted d ON c.[directoryId] = d.[directoryId]; -- DSyncTeamGroupMapping.directory
  UPDATE c SET c.[createdByDSyncId] = NULL FROM [dbo].[AttributeToUser] c INNER JOIN deleted d ON c.[createdByDSyncId] = d.[directoryId]; -- AttributeToUser.createdByDSync
  UPDATE c SET c.[updatedByDSyncId] = NULL FROM [dbo].[AttributeToUser] c INNER JOIN deleted d ON c.[updatedByDSyncId] = d.[directoryId]; -- AttributeToUser.updatedByDSync
END');
EXEC(N'CREATE TRIGGER [dbo].[EventType_emulated_on_delete] ON [dbo].[EventType] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @gone TABLE ([id] INT PRIMARY KEY);
  WITH tree AS (SELECT [id] FROM deleted UNION ALL SELECT c.[id] FROM [dbo].[EventType] c INNER JOIN tree t ON c.[parentId] = t.[id]) INSERT INTO @gone SELECT DISTINCT [id] FROM tree OPTION (MAXRECURSION 100);
  UPDATE c SET c.[eventTypeId] = NULL FROM [dbo].[Booking] c INNER JOIN @gone d ON c.[eventTypeId] = d.[id]; -- Booking.eventType
  DELETE c FROM [dbo].[Webhook] c INNER JOIN @gone d ON c.[eventTypeId] = d.[id]; -- Webhook.eventType
  DELETE p FROM [dbo].[EventType] p INNER JOIN @gone g ON p.[id] = g.[id]; -- EventType.parent
END');
EXEC(N'CREATE TRIGGER [dbo].[FilterSegment_emulated_on_delete] ON [dbo].[FilterSegment] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[UserFilterSegmentPreference] c INNER JOIN deleted d ON c.[segmentId] = d.[id]; -- UserFilterSegmentPreference.segment
END');
EXEC(N'CREATE TRIGGER [dbo].[HostGroup_emulated_on_delete] ON [dbo].[HostGroup] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[groupId] = NULL FROM [dbo].[Host] c INNER JOIN deleted d ON c.[groupId] = d.[id]; -- Host.group
END');
EXEC(N'CREATE TRIGGER [dbo].[IntegrationAttributeSync_emulated_on_delete] ON [dbo].[IntegrationAttributeSync] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[AttributeSyncFieldMapping] c INNER JOIN deleted d ON c.[integrationAttributeSyncId] = d.[id]; -- AttributeSyncFieldMapping.integrationAttributeSync
END');
EXEC(N'CREATE TRIGGER [dbo].[MonthlyProration_emulated_on_delete] ON [dbo].[MonthlyProration] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[processedInProrationId] = NULL FROM [dbo].[SeatChangeLog] c INNER JOIN deleted d ON c.[processedInProrationId] = d.[id]; -- SeatChangeLog.proration
END');
EXEC(N'CREATE TRIGGER [dbo].[OrganizationBilling_emulated_on_delete] ON [dbo].[OrganizationBilling] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[organizationBillingId] = NULL FROM [dbo].[SeatChangeLog] c INNER JOIN deleted d ON c.[organizationBillingId] = d.[id]; -- SeatChangeLog.organizationBilling
  UPDATE c SET c.[organizationBillingId] = NULL FROM [dbo].[MonthlyProration] c INNER JOIN deleted d ON c.[organizationBillingId] = d.[id]; -- MonthlyProration.organizationBilling
END');
EXEC(N'CREATE TRIGGER [dbo].[OutOfOfficeReason_emulated_on_delete] ON [dbo].[OutOfOfficeReason] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[reasonId] = NULL FROM [dbo].[OutOfOfficeEntry] c INNER JOIN deleted d ON c.[reasonId] = d.[id]; -- OutOfOfficeEntry.reason
END');
EXEC(N'CREATE TRIGGER [dbo].[PlatformBilling_emulated_on_delete] ON [dbo].[PlatformBilling] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[managerBillingId] = NULL FROM [dbo].[PlatformBilling] c INNER JOIN deleted d ON c.[managerBillingId] = d.[id]; -- PlatformBilling.managerBilling
END');
EXEC(N'CREATE TRIGGER [dbo].[PlatformOAuthClient_emulated_on_delete] ON [dbo].[PlatformOAuthClient] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[Webhook] c INNER JOIN deleted d ON c.[platformOAuthClientId] = d.[id]; -- Webhook.platformOAuthClient
END');
EXEC(N'CREATE TRIGGER [dbo].[Profile_emulated_on_delete] ON [dbo].[Profile] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[profileId] = NULL FROM [dbo].[EventType] c INNER JOIN deleted d ON c.[profileId] = d.[id]; -- EventType.profile
  UPDATE c SET c.[movedToProfileId] = NULL FROM [dbo].[users] c INNER JOIN deleted d ON c.[movedToProfileId] = d.[id]; -- User.movedToProfile
END');
EXEC(N'CREATE TRIGGER [dbo].[Role_emulated_on_delete] ON [dbo].[Role] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[customRoleId] = NULL FROM [dbo].[Membership] c INNER JOIN deleted d ON c.[customRoleId] = d.[id]; -- Membership.customRole
END');
EXEC(N'CREATE TRIGGER [dbo].[Schedule_emulated_on_delete] ON [dbo].[Schedule] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[scheduleId] = NULL FROM [dbo].[Host] c INNER JOIN deleted d ON c.[scheduleId] = d.[id]; -- Host.schedule
  UPDATE c SET c.[scheduleId] = NULL FROM [dbo].[EventType] c INNER JOIN deleted d ON c.[scheduleId] = d.[id]; -- EventType.schedule
  UPDATE c SET c.[instantMeetingScheduleId] = NULL FROM [dbo].[EventType] c INNER JOIN deleted d ON c.[instantMeetingScheduleId] = d.[id]; -- EventType.instantMeetingSchedule
  UPDATE c SET c.[restrictionScheduleId] = NULL FROM [dbo].[EventType] c INNER JOIN deleted d ON c.[restrictionScheduleId] = d.[id]; -- EventType.restrictionSchedule
  UPDATE c SET c.[scheduleId] = NULL FROM [dbo].[Availability] c INNER JOIN deleted d ON c.[scheduleId] = d.[id]; -- Availability.Schedule
END');
EXEC(N'CREATE TRIGGER [dbo].[Team_emulated_on_delete] ON [dbo].[Team] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @gone TABLE ([id] INT PRIMARY KEY);
  WITH tree AS (SELECT [id] FROM deleted UNION ALL SELECT c.[id] FROM [dbo].[Team] c INNER JOIN tree t ON c.[parentId] = t.[id]) INSERT INTO @gone SELECT DISTINCT [id] FROM tree OPTION (MAXRECURSION 100);
  UPDATE c SET c.[organizationId] = NULL FROM [dbo].[users] c INNER JOIN @gone d ON c.[organizationId] = d.[id]; -- User.organization
  DELETE c FROM [dbo].[Membership] c INNER JOIN @gone d ON c.[teamId] = d.[id]; -- Membership.team
  DELETE c FROM [dbo].[PlatformOAuthClient] c INNER JOIN @gone d ON c.[organizationId] = d.[id]; -- PlatformOAuthClient.organization
  DELETE c FROM [dbo].[ManagedOrganization] c INNER JOIN @gone d ON c.[managerOrganizationId] = d.[id]; -- ManagedOrganization.managerOrganization
  DELETE c FROM [dbo].[DelegationCredential] c INNER JOIN @gone d ON c.[organizationId] = d.[id]; -- DelegationCredential.organization
  DELETE p FROM [dbo].[Team] p INNER JOIN @gone g ON p.[id] = g.[id]; -- Team.parent
END');
EXEC(N'CREATE TRIGGER [dbo].[TeamBilling_emulated_on_delete] ON [dbo].[TeamBilling] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[teamBillingId] = NULL FROM [dbo].[SeatChangeLog] c INNER JOIN deleted d ON c.[teamBillingId] = d.[id]; -- SeatChangeLog.teamBilling
  UPDATE c SET c.[teamBillingId] = NULL FROM [dbo].[MonthlyProration] c INNER JOIN deleted d ON c.[teamBillingId] = d.[id]; -- MonthlyProration.teamBilling
END');
EXEC(N'CREATE TRIGGER [dbo].[users_emulated_on_delete] ON [dbo].[users] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  DELETE c FROM [dbo].[EventType] c INNER JOIN deleted d ON c.[userId] = d.[id]; -- EventType.owner
  DELETE c FROM [dbo].[Membership] c INNER JOIN deleted d ON c.[userId] = d.[id]; -- Membership.user
  DELETE c FROM [dbo].[Booking] c INNER JOIN deleted d ON c.[userId] = d.[id]; -- Booking.user
  UPDATE c SET c.[reassignById] = NULL FROM [dbo].[Booking] c INNER JOIN deleted d ON c.[reassignById] = d.[id]; -- Booking.reassignBy
  UPDATE c SET c.[userId] = NULL FROM [dbo].[OAuthClient] c INNER JOIN deleted d ON c.[userId] = d.[id]; -- OAuthClient.user
  DELETE c FROM [dbo].[OutOfOfficeEntry] c INNER JOIN deleted d ON c.[toUserId] = d.[id]; -- OutOfOfficeEntry.toUser
  DELETE c FROM [dbo].[SecondaryEmail] c INNER JOIN deleted d ON c.[userId] = d.[id]; -- SecondaryEmail.user
  UPDATE c SET c.[updatedById] = NULL FROM [dbo].[AttributeToUser] c INNER JOIN deleted d ON c.[updatedById] = d.[id]; -- AttributeToUser.updatedBy
  UPDATE c SET c.[reviewedById] = NULL FROM [dbo].[WrongAssignmentReport] c INNER JOIN deleted d ON c.[reviewedById] = d.[id]; -- WrongAssignmentReport.reviewedBy
END');
EXEC(N'CREATE TRIGGER [dbo].[Watchlist_emulated_on_delete] ON [dbo].[Watchlist] AFTER DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET c.[globalWatchlistId] = NULL FROM [dbo].[BookingReport] c INNER JOIN deleted d ON c.[globalWatchlistId] = d.[id]; -- BookingReport.globalWatchlist
END');


COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH

