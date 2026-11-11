const communityDriveFiles = [
  "1P3vVYnC9A-SXjQOKJ9yBQZJ-0OxEVDDO",
  "1--K2oJlufYZNpSkw8kFXAOlVzxjB7CfP",
  "1R0Pmlmck38kK9ql5dx1a33n_lQb-5s01",
  "1jMRn59be4v_i54cQbrEiGrW6DpqslAtP",
  "1iveng-E8Kx42wCckMzdgRPr6ZhX2uiG3",
  "1QMGsaSEwmjtZb3SL0BhrqZZuypYbTUEV",
  "1lOBJhF_uKFvcBkMuSAMDWZwoJAqeJ7VJ",
  "1Vqw1JT02Zpzb9m253hDsDft-qaIecvo0",
  "1Kqt8p9vlTwjk0F-jbNQh0n-gnLq-fCS2",
  "1wAMkLjg2VK6HNIuVM0g0RtU-ZEW39jeL",
  "1HV3mVIYaeqBwXfPOureiVg_BZFfiFVeu",
  "1WdSaVJYR0Gj8D3ZF9I4CsP_Vn9_V-Zj8",
  "1MVEGjxtBodp1I-ys1pThRol8pHGNAWEx",
  "1OjI2vhNm9RgEKdbxvbnNaAcTGGkZYXCb",
  "1n3qJXbnrYyLgjFb5LPovrHRqZ0WugMji",
  "1VGelzbRgFL2J6eCuoocAZSL4bV1BkJWM",
  "1VrW15WEsCSF_0kPLOTpMkCK3Y2JWBWYU",
  "1XMjbaKytK7Ya6D-duP0UqnyaASKHb9lu",
  "1t8TdqZKyv4w10tB51FRmYrzjagpcnCda",
  "16VoNjCjMzbTdITnotem2Ba9xvL36RzC2",
  "1-OR9xqL7JQIWN8SOv65qDzRlUngqqUUB",
  "1R22m310cADsKf3Q0ANSitS9f_9b0zWeh",
  "1DCmCqPwKgrNYXLpZqgLowEUQpzni44FR",
  "1fDl2HUYYh91w6evt_tz4kdHFwcFRGCUS",
  "1T13ylG2O6gpcWDmyjzXikevlTowlA3qG",
  "1GhUyhfoafBYg9fKgpuhDNaZAi4f4KZ4u",
  "1UqxO4s3ZxKg5cWEfK1DiNRtr60O7DY1x",
  "1HDOed2vn7xIy7FVAdZgYonAOmOmTXzEk",
  "1I3yXl5AKTTWux91_JSfT7DoMWMwpFwfj",
  "1qqWAhn3vGHWFw3tV-uenTZyqLXQpVaRr",
  "1YqPPdUQYZO__UKDuZ2u4sOr8wh_T6FIo",
  "1C5-4SiK0EI60_czzrYdoQdIAB0Sl6Dpv",
  "1Fq8nO2PDt4WnVpaEbKW0agE5CIG9GyGW",
  "1-G-pp07pjpGl3ykMObKtM2ejy8xB6M_q",
  "1bEujX8Viwo62OxIKAfuZ0NSk6r3TPLnk",
  "1JdU7oUZO1Ao_5Wx62kA2ck0PKF3tjiOA",
  "1wIQlpyKLSODdWsxH4WHH8-86MGFzh-hG",
  "1p7xg0txrmmOERSlQiQx3BtDMPyXwtUKS",
  "1rgPrO9rBDCyLHWaHO7lErL8xxdKJsRj1",
  "1KFN19YtW5hbE8dIVtfJC8U8KjzcChCBz",
  "1PXfcXJWqrilQ1QSlXPybp0Ex_T2JDGFj",
  "1dElrLroQmq9ckqetOLYeh9SC4mE0IbYp",
  "1teeorjMdRFhQTqU_DNDlcadGUWzi8vLR",
  "1qNrpj0Q_MTgYiyze3ReroGEpI_wsxjbP",
  "1YCea61XzWkgSD-7yrJOBcI9XXPpjCBGz",
  "14SdIDHtTB50Psy6NicCXn5C9DBRJD_r7",
  "1BAcIqx1a-jQyJLQzl6ot0dSV7mC-w4Xj",
  "1w9Wbp0VM7Y_9GDR_Zp0diE_YKthz7X7h",
  "1wfOlA41fsce9tnD5CZi9s74sxRsEhQAD",
  "1UQDqQmqf4VW7d-tmt5kX6qdaXbJ2QztN",
  "1FosEespDcKb0CNYX-gXVM8kDhsP2EGDZ",
  "1T3x6RTguGAP3HHHt83r3Ly5hSqKzSx7H",
  "1LhwpxYLWAf2fgqmJ628eh1K3np4Hseom",
  "1AmNpxAQLZBgNc0hoQpxb7yIvZGINcdnr",
  "1SJxVZSw5MPHeoqw_p_wfGXti6AyvhXZe"
];

const communityGallery = document.querySelector("#community-gallery");

if (!communityGallery) {
  throw new Error("Community gallery container was not found.");
}

const galleryFragment = document.createDocumentFragment();
const videoId = "16VoNjCjMzbTdITnotem2Ba9xvL36RzC2";

communityDriveFiles.forEach((fileId, index) => {
  const isVideo = fileId === videoId;
  const item = document.createElement("a");
  item.className = "community-gallery-item";
  item.href = `https://drive.google.com/file/d/${fileId}/view?usp=sharing`;
  item.target = "_blank";
  item.rel = "noopener noreferrer";
  item.setAttribute(
    "aria-label",
    `Open community ${isVideo ? "video" : "photo"} ${index + 1} in Google Drive`
  );

  const image = document.createElement("img");
  image.src = `https://drive.google.com/thumbnail?id=${fileId}&sz=w1000`;
  image.alt = `Community ${isVideo ? "video" : "photo"} ${index + 1}`;
  image.loading = "lazy";
  image.decoding = "async";
  image.addEventListener("error", () => {
    item.classList.add("preview-unavailable");
    image.alt = "";
  });
  item.append(image);

  const fallback = document.createElement("span");
  fallback.className = "gallery-fallback";
  fallback.textContent = "Preview unavailable — open in Drive";
  item.append(fallback);

  if (isVideo) {
    const badge = document.createElement("span");
    badge.className = "gallery-video-badge";
    badge.textContent = "Video";
    item.append(badge);
  }

  galleryFragment.append(item);
});

communityGallery.replaceChildren(galleryFragment);
