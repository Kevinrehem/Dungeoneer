# Form Validation

For all user inputs, we strictly mandate the use of **Zod** for schema definition and **React Hook Form** for state management, integrated tightly with `shadcn/ui` components.

## 1. Define Zod Schema

Always define the schema outside of the component to prevent recreation on re-renders.

```tsx
import { z } from "zod";

export const characterFormSchema = z.object({
  name: z.string().min(2, {
    message: "Name must be at least 2 characters.",
  }).max(50),
  ruleset: z.enum(["SRD_2014", "SRD_2024"]),
});

export type CharacterFormValues = z.infer<typeof characterFormSchema>;
```

## 2. Integration with shadcn/ui Form

```tsx
"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { characterFormSchema, CharacterFormValues } from "./schema";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

export function CharacterForm({ onSubmit }: { onSubmit: (data: CharacterFormValues) => void }) {
  const form = useForm<CharacterFormValues>({
    resolver: zodResolver(characterFormSchema),
    defaultValues: {
      name: "",
      ruleset: "SRD_2024",
    },
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Character Name</FormLabel>
              <FormControl>
                <Input placeholder="Gandalf" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Create Character</Button>
      </form>
    </Form>
  );
}
```
