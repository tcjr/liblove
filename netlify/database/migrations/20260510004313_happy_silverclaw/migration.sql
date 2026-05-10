ALTER TABLE "libraries" ADD COLUMN "metro" text;

UPDATE "libraries" SET "metro" = 'chicago';