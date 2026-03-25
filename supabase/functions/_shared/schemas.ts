import { z } from "npm:zod@3";

export const rewriteBody = z.object({
  message: z.string().min(1).max(20_000),
  context: z.string().max(200).default("general"),
});

export const analyzeToneBody = z.object({
  message: z.string().min(1).max(20_000),
});

export const roleplayBody = z.object({
  sessionId: z.string().uuid().optional(),
  scenario: z.string().min(1).max(500),
  userMessage: z.string().min(1).max(10_000),
});

export const insightsBody = z.object({}).passthrough();

export const listMessagesBody = z.object({
  limit: z.number().int().min(1).max(100).optional().default(40),
  offset: z.number().int().min(0).max(10_000).optional().default(0),
});

export const updateProfileBody = z.object({
  communication_goal: z.string().max(500).optional(),
  tone_style: z.string().max(200).optional(),
  challenges: z.array(z.string().max(200)).max(20).optional(),
  name: z.string().max(200).optional(),
});
