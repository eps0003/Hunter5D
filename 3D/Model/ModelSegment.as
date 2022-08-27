#include "Vec3f"

shared class ModelSegment
{
	Vec3f position;
	Vec3f rotation;
	float scale = 1.0f;

	private SMesh mesh;
	private ModelSegment@[] children;
	private float[] matrix;

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

	void Render(float[] matrix, float t)
	{
		Transform(matrix);

		mesh.RenderMeshWithMaterial();

		for (uint i = 0; i < children.size(); i++)
		{
			children[i].Render(matrix, t);
		}
	}

	private void Transform(float[]@ matrix)
	{
		Matrix::MakeIdentity(this.matrix);

		Matrix::SetTranslation(this.matrix, position.x, position.y, position.z);
		Matrix::SetRotationDegrees(this.matrix, -rotation.x, -rotation.y, -rotation.z);

		float[] scaleMatrix;
		Matrix::MakeIdentity(scaleMatrix);
		Matrix::SetScale(scaleMatrix, scale, scale, scale);

		Matrix::MultiplyImmediate(this.matrix, scaleMatrix);
		Matrix::MultiplyImmediate(matrix, this.matrix);
		Render::SetModelTransform(matrix);

		this.matrix = matrix;
	}
}
