-- CreateTable
CREATE TABLE "User" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "currentlySelected" BOOLEAN NOT NULL,
    "targetWorkTimePerWeek" INTEGER NOT NULL
);

-- CreateTable
CREATE TABLE "GlobalSetting" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "userId" INTEGER NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    CONSTRAINT "GlobalSetting_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "WeekDaySetting" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "userId" INTEGER NOT NULL,
    "day" TEXT NOT NULL,
    "timeEquivalent" INTEGER NOT NULL,
    "mandatoryWorkTimeStart" INTEGER NOT NULL,
    "mandatoryWorkTimeEnd" INTEGER NOT NULL,
    "defaultWorkTimeStart" INTEGER NOT NULL,
    "defaultWorkTimeEnd" INTEGER NOT NULL,
    "defaultBreakDuration" INTEGER NOT NULL,
    CONSTRAINT "WeekDaySetting_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "EventSetting" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "userId" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT,
    "startDate" DATETIME NOT NULL,
    "endDate" DATETIME NOT NULL,
    "startIsHalfDay" BOOLEAN NOT NULL,
    "endIsHalfDay" BOOLEAN NOT NULL,
    CONSTRAINT "EventSetting_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "DayBasedRepetitionRule" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "eventId" INTEGER NOT NULL,
    "repeatAfterDays" INTEGER NOT NULL,
    CONSTRAINT "DayBasedRepetitionRule_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "EventSetting" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "MonthBasedRepetitionRule" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "eventId" INTEGER NOT NULL,
    "repeatAfterMonths" INTEGER NOT NULL,
    "dayIndex" INTEGER NOT NULL,
    "weekIndex" INTEGER,
    "countFromEnd" BOOLEAN NOT NULL,
    CONSTRAINT "MonthBasedRepetitionRule_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "EventSetting" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "DayValue" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "userId" INTEGER NOT NULL,
    "date" DATETIME NOT NULL,
    "firstHalfMode" TEXT NOT NULL,
    "secondHalfMode" TEXT NOT NULL,
    "workTimeStart" INTEGER NOT NULL,
    "workTimeEnd" INTEGER NOT NULL,
    "breakDuration" INTEGER NOT NULL,
    CONSTRAINT "DayValue_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "WeekValue" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "userId" INTEGER NOT NULL,
    "weekStartDate" DATETIME NOT NULL,
    "targetTime" INTEGER NOT NULL,
    CONSTRAINT "WeekValue_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "User_name_key" ON "User"("name");

-- CreateIndex
CREATE UNIQUE INDEX "GlobalSetting_userId_key_key" ON "GlobalSetting"("userId", "key");

-- CreateIndex
CREATE UNIQUE INDEX "WeekDaySetting_userId_day_key" ON "WeekDaySetting"("userId", "day");

-- CreateIndex
CREATE UNIQUE INDEX "DayValue_userId_date_key" ON "DayValue"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "WeekValue_userId_weekStartDate_key" ON "WeekValue"("userId", "weekStartDate");
