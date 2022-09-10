#include "Vec3f"

shared class ModelSegment
{
	Vec3f initialOffset;
	Vec3f initialOrigin;
	Vec3f initialRotation;
	float initialScale = 1.0f;

	Vec3f offset; // Offset from parent
	Vec3f origin; // Origin of rotation
	Vec3f rotation; // Rotation around origin (TODO: use quaternion)
	float scale = 1.0f;

	private SMesh mesh;
	private ModelSegment@[] children;
	private CMatrix matrix;

	ModelSegment(string modelPath, string texture)
	{
		mesh.LoadObjIntoMesh(modelPath);
		SetMaterial(texture);
	}

	private void SetMaterial(string texture)
	{
		SMaterial material;
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);
		mesh.SetMaterial(material);
	}

	ModelSegment@ SetTexture(string texture)
	{
		SetMaterial(texture);
		return this;
	}

	ModelSegment@ AddChild(ModelSegment@ segment)
	{
		children.push_back(segment);
		return this;
	}

	ModelSegment@ SetParent(ModelSegment@ segment)
	{
		segment.AddChild(this);
		return this;
	}

	void Render(CMatrix matrix, float t)
	{
		Transform(matrix);

		mesh.RenderMeshWithMaterial();

		for (uint i = 0; i < children.size(); i++)
		{
			children[i].Render(matrix, t);
		}
	}

	private void Transform(CMatrix@ matrix)
	{
		CMatrix initialOriginMatrix;
		initialOriginMatrix.SetTranslation(-initialOrigin);

		CMatrix initialRotationMatrix;
		initialRotationMatrix.SetRotation(initialRotation);

		CMatrix initialOffsetMatrix;
		initialOffsetMatrix.SetTranslation(initialOffset);

		CMatrix initialScaleMatrix;
		initialScaleMatrix.SetScale(initialScale);

		matrix *= initialOffsetMatrix * initialScaleMatrix * (initialRotationMatrix * initialOriginMatrix);
		this.matrix = matrix;

		Render::SetModelTransform(matrix.toArray());
	}
}
