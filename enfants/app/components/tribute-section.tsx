"use client";

import { FormEvent, useEffect, useState } from "react";

type Tribute = {
  id: number;
  displayName: string;
  message: string;
  createdAt: string;
};

export function TributeSection() {
  const [tributes, setTributes] = useState<Tribute[]>([]);
  const [displayName, setDisplayName] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState<"idle" | "sending" | "sent" | "error">("idle");

  useEffect(() => {
    fetch("/api/tributes")
      .then((response) => (response.ok ? response.json() : { tributes: [] }))
      .then((data) => setTributes(data.tributes ?? []))
      .catch(() => setTributes([]));
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus("sending");
    const form = new FormData(event.currentTarget);
    try {
      const response = await fetch("/api/tributes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          displayName,
          message,
          website: form.get("website"),
        }),
      });
      if (!response.ok) throw new Error("submission failed");
      setDisplayName("");
      setMessage("");
      setStatus("sent");
    } catch {
      setStatus("error");
    }
  }

  return (
    <section className="tributes" id="hommages" aria-labelledby="tributes-title">
      <div className="tributes__heading">
        <p className="eyebrow">Une lumière pour leur mémoire</p>
        <h2 id="tributes-title">Déposer un hommage</h2>
        <p>
          Écrivez quelques mots sobres. Les messages sont relus avant leur
          publication afin de préserver la dignité de cet espace.
        </p>
      </div>

      <form className="tribute-form" onSubmit={submit}>
        <label>
          <span>Votre prénom ou signature</span>
          <input
            required
            maxLength={80}
            value={displayName}
            onChange={(event) => setDisplayName(event.target.value)}
            placeholder="Ex. Marie, Lyon"
          />
        </label>
        <label>
          <span>Votre message</span>
          <textarea
            required
            minLength={5}
            maxLength={500}
            rows={5}
            value={message}
            onChange={(event) => setMessage(event.target.value)}
            placeholder="Quelques mots pour honorer leur mémoire…"
          />
          <small>{message.length}/500 caractères</small>
        </label>
        <label className="honeypot" aria-hidden="true">
          Site internet
          <input name="website" tabIndex={-1} autoComplete="off" />
        </label>
        <button className="button" type="submit" disabled={status === "sending"}>
          {status === "sending" ? "Envoi…" : "Allumer une bougie virtuelle"}
        </button>
        <div className="form-status" aria-live="polite">
          {status === "sent" && "Merci. Votre hommage sera publié après vérification."}
          {status === "error" && "L’hommage n’a pas pu être envoyé. Réessayez dans un instant."}
        </div>
      </form>

      {tributes.length > 0 && (
        <div className="tribute-list" aria-label="Hommages publiés">
          {tributes.map((tribute) => (
            <blockquote key={tribute.id}>
              <span className="tribute-list__light" aria-hidden="true">✦</span>
              <p>{tribute.message}</p>
              <footer>— {tribute.displayName}</footer>
            </blockquote>
          ))}
        </div>
      )}
    </section>
  );
}
