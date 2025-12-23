import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";

const client = new ElevenLabsClient({
  apiKey: process.env.ELEVENLABS_API_KEY ?? "",
});

export async function textToSpeech(text: string, voiceId?: string): Promise<Buffer> {
  const vid = voiceId ?? process.env.ELEVENLABS_VOICE_ID ?? "21m00Tcm4TlvDq8ikWAM"; // Rachel voice

  const audio = await client.textToSpeech.convert(vid, {
    text,
    model_id: "eleven_multilingual_v2",
  });

  const chunks: Buffer[] = [];
  for await (const chunk of audio) {
    chunks.push(Buffer.from(chunk));
  }

  return Buffer.concat(chunks);
}

export async function streamTextToSpeech(text: string, voiceId?: string): Promise<AsyncIterable<Buffer>> {
  const vid = voiceId ?? process.env.ELEVENLABS_VOICE_ID ?? "21m00Tcm4TlvDq8ikWAM";

  const audio = await client.textToSpeech.convertAsStream(vid, {
    text,
    model_id: "eleven_multilingual_v2",
  });

  return audio as AsyncIterable<Buffer>;
}

export async function getVoices() {
  const response = await client.voices.getAll();
  return response.voices;
}
