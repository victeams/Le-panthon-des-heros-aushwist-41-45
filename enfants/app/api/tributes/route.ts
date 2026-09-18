import { desc, eq } from "drizzle-orm";
import { getDb } from "../../../db";
import { tributes } from "../../../db/schema";

function messageFromError(error: unknown) {
  const message = error instanceof Error ? error.message : "Erreur inattendue";
  if (message.includes("no such table") || message.includes("tributes")) {
    return "L’espace d’hommage est en cours d’installation.";
  }
  return "L’espace d’hommage est momentanément indisponible.";
}

export async function GET() {
  try {
    const db = getDb();
    const rows = await db
      .select({
        id: tributes.id,
        displayName: tributes.displayName,
        message: tributes.message,
        createdAt: tributes.createdAt,
      })
      .from(tributes)
      .where(eq(tributes.status, "approved"))
      .orderBy(desc(tributes.createdAt), desc(tributes.id))
      .limit(24);
    return Response.json({ tributes: rows });
  } catch (error) {
    return Response.json({ error: messageFromError(error), tributes: [] }, { status: 503 });
  }
}

export async function POST(request: Request) {
  try {
    const payload = (await request.json()) as {
      displayName?: string;
      message?: string;
      website?: string;
    };

    if (payload.website) {
      return Response.json({ received: true }, { status: 201 });
    }

    const displayName = payload.displayName?.trim() ?? "";
    const message = payload.message?.trim() ?? "";

    if (displayName.length < 2 || displayName.length > 80) {
      return Response.json({ error: "Signature invalide." }, { status: 400 });
    }
    if (message.length < 5 || message.length > 500) {
      return Response.json({ error: "Message invalide." }, { status: 400 });
    }

    const db = getDb();
    await db.insert(tributes).values({ displayName, message, status: "pending" });
    return Response.json({ received: true }, { status: 201 });
  } catch (error) {
    return Response.json({ error: messageFromError(error) }, { status: 503 });
  }
}
