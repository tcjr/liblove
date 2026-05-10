ALTER TABLE "libraries" ADD COLUMN "metro" text;
--> statement-breakpoint
UPDATE "libraries" SET "metro" = 'chicago';
--> statement-breakpoint
ALTER TABLE "libraries" ALTER COLUMN "metro" SET NOT NULL;
